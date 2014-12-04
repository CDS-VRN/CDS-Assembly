package nl.idgis.cds.assembly;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;

import javax.xml.namespace.QName;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamReader;
import javax.xml.stream.XMLStreamWriter;

public class XMLConfigReport {

	static class Bronhouder {
		File file;
		HashMap<String, File> datasets = new HashMap<String, File>();
	}

	public static void main(String[] args) throws Exception {
		try {

			if(args.length == 2) {
				File dir = new File(args[0]);
				File output = new File(args[1]);
				if(output.exists()) {
					output.delete();
				}

				if(dir.isDirectory()) {
					HashMap<String, Bronhouder> bronhouders = new HashMap<String, Bronhouder>();
					for (File file : dir.listFiles()) {						
						String[] fileName = file.getName().split("\\.");						

						String bronhouderCode = fileName[0];
						Bronhouder bronhouder = bronhouders.get(bronhouderCode);
						if (bronhouder == null) {
							bronhouder = new Bronhouder();
							bronhouders.put(bronhouderCode, bronhouder);
						}

						switch (fileName.length) {
						case 2:
							bronhouder.file = file;							
							break;
						case 3:
							String datasetCode = fileName[1];
							bronhouder.datasets.put(datasetCode, file);							
						}
					}

					XMLOutputFactory outputFactory = XMLOutputFactory
							.newInstance();
					XMLInputFactory inputFactory = XMLInputFactory
							.newInstance();

					output.getParentFile().mkdirs();
					FileOutputStream fos = new FileOutputStream(output);					
					XMLStreamWriter writer = outputFactory
							.createXMLStreamWriter(fos);
					
					writer.writeStartDocument();
					writer.writeStartElement("Report");
					
					for(String bronhouderCode : bronhouders.keySet()) {
						Bronhouder bronhouder = bronhouders.get(bronhouderCode);
						
						HashSet<String> expectedNames = new HashSet<String>();
						expectedNames.add("geometry");
						expectedNames.add("legalFoundationDate");
						expectedNames.add("legalFoundationDocument");
						expectedNames.add("siteName");
						expectedNames.add("siteDesignation");
						expectedNames.add("siteProtectionClassification");
						expectedNames.add("percentageUnderDesignation");						
						expectedNames.add("inspireID");						
						
						writer.writeStartElement("Bronhouder");
							writer.writeStartElement("Code");
								writer.writeCharacters(bronhouderCode);								
							writer.writeEndElement();
							fileReport(inputFactory.createXMLStreamReader(
								new FileInputStream(bronhouder.file)), writer, expectedNames, false);
							
							for(String datasetCode : bronhouder.datasets.keySet()) {
								writer.writeStartElement("Dataset");
									writer.writeStartElement("Code");
										writer.writeCharacters(datasetCode);
									writer.writeEndElement();
									
									HashSet<String> datasetExpectedNames = new HashSet<String>(expectedNames);
									fileReport(inputFactory.createXMLStreamReader(
										new FileInputStream(bronhouder.datasets.get(datasetCode))), writer, 
											datasetExpectedNames, true);
								writer.writeEndElement();
							}
						writer.writeEndElement();
					}
					
					writer.writeEndElement();
					writer.writeEndDocument();
					
					fos.close();
				}
			}
		} catch(Exception e) {
			e.printStackTrace();
			throw e;
		}
	}
	
	static void fileReport(XMLStreamReader reader, XMLStreamWriter writer, HashSet<String> expectedNames, boolean printExpectedNames) throws Exception {
		String gmlVersion = null;
		
		StringBuilder stringBuilder = null;
		boolean inReplace = false;
		
		HashSet<String> namespaces = new HashSet<String>();		
		ArrayList<String[]> wrongNames = new ArrayList<String[]>();
		while(reader.hasNext()) {
			if(reader.isStartElement()) {
				stringBuilder = new StringBuilder();
				
				if(reader.getLocalName().equals("replace")) {
					inReplace = true;
				}
			}
			
			if(reader.isCharacters()) {
				stringBuilder.append(reader.getText());
			}
			
			if(reader.isEndElement()) {
				if(reader.getLocalName().equals("gmlVersion")) {
					gmlVersion = stringBuilder.toString();
				} else if(reader.getLocalName().equals("replace")) {
					inReplace = false;
				}
				
				if(inReplace) {
					QName name = reader.getName();
					namespaces.add(name.getNamespaceURI());
					
					String flatName = stringBuilder.toString();
					String flatLocalName = flatName.split(":")[1];
					
					expectedNames.remove(flatLocalName);
					
					String localName = name.getLocalPart();
					if(!flatLocalName.equals(localName)) {
						wrongNames.add(new String[]{localName, flatLocalName});
					}
				}
			}
			
			reader.next();
		}
		
		if(gmlVersion != null) {
			writer.writeStartElement("GmlVersion");
				writer.writeCharacters(gmlVersion);
			writer.writeEndElement();
		}
		
		if(namespaces.size() > 0) {
			writer.writeStartElement("Namespaces");
				for(String namespace : namespaces) {
					writer.writeStartElement("Namespace");
						writer.writeCharacters(namespace);
					writer.writeEndElement();
				}
			writer.writeEndElement();
		}
		
		if(wrongNames.size() > 0) {
			writer.writeStartElement("WrongNames");
				for(String[] wrongName : wrongNames) {
					writer.writeStartElement("Name");
						writer.writeAttribute("found", wrongName[0]);
						writer.writeAttribute("expected", wrongName[1]);
					writer.writeEndElement();
				}
			writer.writeEndElement();
		}
		
		if(printExpectedNames && expectedNames.size() > 0) {
			writer.writeStartElement("MissingNames");
			for(String expectedName : expectedNames) {
				writer.writeStartElement("Name");					
					writer.writeAttribute("expected", expectedName);
				writer.writeEndElement();
			}
			writer.writeEndElement();
		}
	}
}
