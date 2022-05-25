<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xslt:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:date="http://exslt.org/dates-and-times" xmlns:str="http://exslt.org/strings"
	xmlns:xslt="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xf="http://www.ecrion.com/xf/1.0" xmlns:xc="http://www.ecrion.com/2008/xc"
	xmlns:xfd="http://www.ecrion.com/xfd/1.0" xmlns:svg="http://www.w3.org/2000/svg"
	xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ns="documents.bind.logic.bakery"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" extension-element-prefixes="date str" 
	xmlns:barcode="http://barcode4j.krysalis.org/ns" exclude-result-prefixes="barcode fo svg">

<!-- 
	Damit man die Dokumente Rechnung und Gutschrift vom Namen bzw. vom Type her unterscheiden kann, sind zwei Stylesheets notwendig.
	Jedes Stylesheet ein DokumentType und eine Konfiguration.
	
	is.oms.dir.var = The name of the property representing the base path of the file system where IOM reads and writes its operational data.
-->
	
<xslt:import href="invoice_credit_note_pdf.xslt" />
	
</xslt:stylesheet>
