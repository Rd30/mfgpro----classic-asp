<!DOCTYPE html>
<html lang="en-us">
	<head>
	  <!-- #include file = "../gp-slo/common/gp-sloHead.html" -->
	</head>
	<body>
		<div id="shipRepLoader"></div> <!-- Page loading -->
		<!-- Dark overlay element -->
		<div class="overlay" id="overlay"></div>

		<!--NavBar/Header-->
		<div class="all-gp-sloHeader" id="shipRepHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->
		<%
			'On Error Resume Next
			Set Conn = Server.CreateObject("ADODB.Connection")
			SPG = "DSN=SPG;UID=mfg;PWD="
			Conn.Open SPG
			
			' If the date is not in the url then assign current date		
			im = Request("im")
			if im = "" then im = Month(date())
			iy = Request("year")
			if iy = "" then iy = Year(date())
			
			' if the bufferdays is not in the url then assign default
			bufferdays = Request("bufferdays")
			if bufferdays = "" then bufferdays = 2
			
			' Result set for first table
			sqlstring = "SELECT tr_prod_line, " & _
					" SUM(- tr_qty_chg), " & _
					" SUM(CASE WHEN tr_effdate <= (tr_per_date + " & bufferdays & " ) THEN (- tr_qty_chg) ELSE 0 END) / " & _
					" (SUM(CASE WHEN tr_effdate <= (tr_per_date + " & bufferdays & " ) THEN (- tr_qty_chg) ELSE 0 END) + " & _
					"  SUM(CASE WHEN tr_effdate > (tr_per_date + " & bufferdays & " ) THEN (- tr_qty_chg) ELSE 0 END)), " & _
					" pl_desc, " & _
					" SUM(CASE WHEN tr_effdate <= (tr_per_date + " & bufferdays & ") THEN (- tr_qty_chg) ELSE 0 END)" & _
					" FROM PUB.tr_hist left join PUB.pl_mstr on tr_prod_line = pl_prod_line " & _
					" WHERE tr_effdate > TO_DATE('01/01/" & CStr(iy) & "') AND tr_part <> '3TP400' AND tr_part <> '3TP600' AND " & _
					" tr_type = 'ISS-SO' AND tr_qty_req <> 0 AND (tr_um = 'EA' OR tr_um = '') " & _
					" GROUP BY tr_prod_line, pl_desc HAVING SUM(- tr_qty_chg) <> 0 "

			set rs = Conn.Execute(sqlstring)
			if not rs.eof then data = rs.getRows()
			rs.close

			
			' Result set for second table
			sqlstring2 = "SELECT " & _
					" year(tr_effdate), month(tr_effdate), " & _
					" SUM(CASE WHEN tr_effdate <= (tr_per_date + " & bufferdays & " ) THEN (- tr_qty_chg) ELSE 0 END) / " & _
					" (SUM(CASE WHEN tr_effdate <= (tr_per_date + " & bufferdays & " ) THEN (- tr_qty_chg) ELSE 0 END) + " & _
					"  SUM(CASE WHEN tr_effdate > (tr_per_date + " & bufferdays & " ) THEN (- tr_qty_chg) ELSE 0 END)), " & _
					" SUM(- tr_qty_chg), " & _
					" SUM(CASE WHEN tr_effdate <= (tr_per_date + " & bufferdays & ") THEN (- tr_qty_chg) ELSE 0 END)" & _
					" FROM PUB.tr_hist left join PUB.pl_mstr on tr_prod_line = pl_prod_line " & _
					" WHERE tr_effdate > TO_DATE('01/01/" & CStr(iy) & "') AND tr_part <> '3TP400' AND tr_part <> '3TP600' AND " & _
					" tr_type = 'ISS-SO' AND tr_qty_req <> 0 AND (tr_um = 'EA' OR tr_um = '') " & _
					" GROUP BY year(tr_effdate), month(tr_effdate) " & _
					" ORDER BY year(tr_effdate), month(tr_effdate)"			
					

			set rs = Conn.Execute(sqlstring2)
			if not rs.eof then mtdata = rs.getRows()
			rs.close
			
			Conn.Close
			set rs = Nothing
			set Conn = Nothing

		%>

	<p align="center"><b><u><font size="6">On Time Shipment Report</font></u></b></p>

	<div align="center">

	<h2 style="margin-bottom: 5px"><b>Data from <%=iy%></b></h2>

	<table width="600" cellpadding="3" cellspacing="0" border="1" bordercolor="#101010" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">
	  <tr>
		<td align="left" width="50" bgcolor="#000000">
				<font size="3" color="#FFFFFF"><b>Group</b></font></td>
		<td align="left" width="250" bgcolor="#000000">
				<font size="3" color="#FFFFFF"><b>Product Line</b></font></td>
		<td align="right" align="right" bgcolor="#000000">
				<font size="3" color="#FFFFFF" ><b>Quantity Shipped</b></font></td>
		<td align="right" bgcolor="#000000">
				<font size="3" color="#FFFFFF"><b>Shipped On Time</b></font></td>
	  </tr>
		<%	

		qtyshipped = 0
		shippedontime = 0
		totqty = 0
		totontime = 0

		for i = lbound(data, 2) to ubound(data, 2) 
			group = data(0,i)
			productline = data(3,i)
			qtyshipped = CDbl(data(1,i))
			shippedontime = CDbl(data(2,i))
		
		%>
		
		<tr>
		<td align="left"><font size="3"><%=group%></font>&nbsp;</td>
		<td align="left"><font size="3"><%=productline%></font>&nbsp;</td>
		<td align="right"><%=qtyshipped%>&nbsp;</td>
		<td align="right"><%if not isNull(shippedontime) then Response.Write(formatNumber(shippedontime * 100, 2))%>%</td>
	  </tr>
		<%		
		
		totqty = totqty + qtyshipped
		totontime = totontime + CDbl(data(4,i))
		next 
		
		%>
	  
		<tr>
		<td align="left" bgcolor="#C0C0C0" colspan="2"><font size="3"><b>Total</b></font></td>
		<td align="right" bgcolor="#C0C0C0" align="right"><b><%=totqty%></b>&nbsp;</td>
		<td align="right" bgcolor="#C0C0C0" align="right"><b><%=formatNumber(totontime / totqty * 100, 2) & "%"%></b>&nbsp;</td>
	  </tr>
	</table>


	<h2 style="margin-bottom: 5px"><b>On Time Data By Month</b></h2>

	<table class="srchResTable" id="shipByMonth" width="600" cellpadding="3" cellspacing="0" border="1" bordercolor="#101010" bordercolorlight="#C0C0C0" bordercolordark="#C0C0C0">
	  <tr>
		<td align="left" width="300" bgcolor="#000000">
				<b><font size="3" color="#FFFFFF">Month</font></b></td>
		<td align="right" bgcolor="#000000" >
				<b><font size="3" color="#FFFFFF">Quantity Shipped</font></b></td>
		<td align="right" bgcolor="#000000">
				<b><font size="3" color="#FFFFFF">Shipped On Time</font></b></td>
	  </tr>
		<%	
		
		mtqtyshipped = 0
		mtshippedontime = 0
		totalqty = 0
		totalontime = 0
		
		for i = lbound(mtdata, 2) to ubound(mtdata, 2) 
		
		mtmonth = mtData(1, i)
		mtyear = mtData(0,i)
		mtqtyshipped = CDbl(mtData(3,i))
		mtshippedontime = CDbl(mtData(2,i))
		%>
	  <tr>
		<td align="left"><font size="3"><b><a href="On_Time_Shipment_Data_Month.asp?im=<%=mtdata(1,i)%>&iy=<%=mtdata(0,i)%>"><%=mtmonth & "/" & mtyear%></a></b></font>&nbsp;</td>
		<td align="right"><%=mtqtyshipped%>&nbsp;</td>
		<td align="right"><%=formatNumber(mtshippedontime * 100, 2) & "%"%>&nbsp;</td>
	  </tr>
		<%	
		totalqty = totalqty + mtqtyshipped
		totalontime = totalontime + CDbl(mtData(4, i))
		next 
		%>
	  <tr>
		<td align="left" bgcolor="#C0C0C0"><font size="3"><b>Total</b></font></td>
		<td align="right" bgcolor="#C0C0C0"><b><%=totalqty%></b>&nbsp;</td>
		<td align="right" bgcolor="#C0C0C0"><b><%=formatNumber(totalontime / totalqty * 100, 2) & "%"%></b>&nbsp;</td>
	  </tr>
	</table>


	<!--
	<p>
	<%	lastyear = CStr(CInt(iy) - 1) %>Show the data for <a href="?year=<%=lastyear%>"><%=lastyear%></a>
	</p>
	-->

	<p>
	<form  method="GET" action="On_Time_Shipment_Report.asp">
	Start year <input type="text" name="year" size="4" value="<%=iy%>"> &nbsp;&nbsp;
	Buffer days <input type="text" name="bufferdays" size="3" value="<%=bufferdays%>">
	<input type="submit" value="Go">
	</form>
	</p>
	</div>
		
		<script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
		<script type="text/javascript">
	      $(document).ready(function () {
	        $('#pageTitleDiv').html("");
	        $('#pageTitleDiv').html("<h5>On Time Shipment Report</h5>");
			$('#shortPageTitleDiv').html("");
			$('#shortPageTitleDiv').html("<h5>Sales</h5>");
			
			$('#shipByMonth a').on('click', function(e){
				var shipRepSpinner = $('#shipRepLoader');	
				shipRepSpinner.show();			
			});
	      })		  
	  </script>

	</body>
</html>