import os
import sys


# See main() method at end of file for overview.

def find_path(graph, start, end):
    stack = [start]
    discovered = set()
    path = []


    # Use text-book DFS.
    while stack:
        current_node = stack.pop()

        path.append(current_node)
        if current_node == end:
            return path

        if current_node not in discovered:
            discovered.add(current_node)

            # If there is no update script from the current node to some newer node there also is no path to the deploy
            # node.
            if current_node not in graph:
                return None

            for node in graph[current_node].keys():
                stack.append(node)
        else:
            raise RuntimeError('Cycle detected, path: %s!' % path)
    return None


def build_update_sequence(current_version, deploy_version, directory, prefix):

    # Use dictionary for graph implementation. Also include sequence numbers if multiple files need to be applied for
    #  a certain version upgrade.
    # A -> {B -> [seq1, seq2], C -> {seq1}}
    graph = {}
    update_required = False
    for file in os.listdir(directory):
        if file.startswith(prefix):
            splitted = file.split('_')

            from_version = splitted[1]
            to_version = splitted[3]

            if from_version not in graph:
                graph[from_version] = {}
            if to_version not in graph[from_version]:
                graph[from_version][to_version] = []
            graph[from_version][to_version].append(file)

            # When we detect some update script to the deploy version, we require an update.
            # Also when an update script from the current version to some future version exists we require an update.
            if to_version == deploy_version or from_version == current_version:
                update_required = True

    # Return nothing when no update is required.
    if not update_required:
        return

    # If we detected some update involving either current_version or deploy_version, we require there is a path from
    # current_version to deploy_version.
    version_path = find_path(graph, current_version, deploy_version)
    if not version_path:
        raise RuntimeError('No update path detected from %s to %s for %s. Make sure you have the appropriate update '
                           'files in place that form a path from the currently running version, to the version '
                           'you want to deploy.' % (current_version, deploy_version, prefix))

    update_sequence_str = ''
    from_idx = 0
    to_idx = 1
    while to_idx < len(version_path):
        for update_file in graph[version_path[from_idx]][version_path[to_idx]]:
            with open(os.path.join(directory, update_file), 'r') as f:
                update_sequence_str += f.read()

        from_idx += 1
        to_idx += 1


    return update_sequence_str

def main():
    """
    Outputs an SQL update sequence within BEGIN COMMIT transaction statements from PREV_VERSION to DEPLOY_VERSION.
    Exits with error code > 0 whenever a cycle exists in the path from PREV_VERSION to DEPLOY_VERSION or when no
    path can be found from PREV_VERSION to DEPLOY_VERSION, but an update script from PREV_VERSION to some
    intermediate version or from some intermediate version to DEPLOY_VERSION exists.
    Outputs an empty transaction if no updates connected to either DEPLOY_VERSION or PREV_VERSION are found.
    :return:
    """
    PREV_VERSION = os.environ.get('PREV_VERSION')
    DEPLOY_VERSION =  os.environ.get('DEPLOY_VERSION')
    if not PREV_VERSION or not DEPLOY_VERSION:
        raise RuntimeError('Please set PREV_VERSION and DEPLOY_VERSION environment variables.')

    if len(sys.argv) < 2:
        raise RuntimeError('Please specify update file dir.')


    inspire_update = build_update_sequence(PREV_VERSION, DEPLOY_VERSION, sys.argv[1], 'inspider')
    vrn_update = build_update_sequence(PREV_VERSION, DEPLOY_VERSION, sys.argv[1], 'vrn')

    print 'BEGIN;'
    print inspire_update if inspire_update else ''
    print vrn_update if vrn_update else ''
    print 'COMMIT;'



if __name__ == "__main__":
    main()