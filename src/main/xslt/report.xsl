<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" doctype-system="http://www.w3.org/TR/html4/strict.dtd" doctype-public="-//W3C//DTD HTML 4.01//EN"/> 
    
    <xsl:template name="reportItem">        
        <xsl:if test="Namespaces/Namespace">
            <xsl:variable name="nsURI" select="Namespaces/Namespace/text()"/>
            <xsl:variable name="parentNsUri" select="ancestor::Bronhouder/Namespaces/Namespace/text()"/>
            <xsl:if test="not($parentNsUri) or $nsURI != $parentNsUri">
                <p>XML Namespace URI: <xsl:value-of select="$nsURI"/></p>
            </xsl:if>
        </xsl:if>
        <xsl:if test="GmlVersion">
            <p>GML versie: <xsl:value-of select="GmlVersion/text()"/></p>
        </xsl:if>
        <xsl:if test="WrongNames">
            <h3>Onjuiste benaming:</h3>
            <table>
                <tr>
                    <th>Gevonden</th>
                    <th>Verwacht</th>
                </tr>
                <xsl:for-each select="WrongNames/Name">
                    <tr>
                        <td><xsl:value-of select="@found"/></td>
                        <td><xsl:value-of select="@expected"/></td>
                    </tr>
                </xsl:for-each>
            </table>
        </xsl:if>
        <xsl:if test="MissingNames">
            <h3>Ontbrekende onderdelen:</h3>
            <ul>
                <xsl:for-each select="MissingNames/Name">
                    <li><xsl:value-of select="@expected"/></li>
                </xsl:for-each>
            </ul>
        </xsl:if>
    </xsl:template>

    <xsl:template match="Bronhouder">
        <h1>Bronhouder: <xsl:value-of select="Code/text()"/></h1>
        <h2>Algemeen:</h2>
        <xsl:call-template name="reportItem"/>
        <xsl:for-each select="Dataset">
            <div class="dataset">
                <h2>Dataset <xsl:value-of select="Code/text()"/></h2>
                <xsl:call-template name="reportItem"/>
            </div>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="/">
        <html>
            <head>                
                <style>
                    table, tr, td, th {border: 1px inset}
                    div.dataset {margin-left: 25px}
                </style>                
            </head>
            <body>
                <xsl:apply-templates/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
