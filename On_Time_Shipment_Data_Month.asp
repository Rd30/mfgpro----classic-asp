<!DOCTYPE html>
<html lang="en-us">
	<head>
		<!-- #include file = "../gp-slo/common/gp-sloHead.html" -->
	</head>

	<body>
		<!-- Dark overlay element -->
		<div class="overlay" id="overlay"></div>

		<!--NavBar/Header-->
		<div class="all-gp-sloHeader" id="supplierSearchHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->
		
		<%	'On Error Resume Next

			Set Conn = Server.CreateObject("ADODB.Connection")
			SPG = "DSN=SPG;UID=mfg;PWD="
			Conn.Open SPG
				
			im = Request("im")
			if im = "" then im = Month(date())
			iy = Request("iy")
			if iy = "" then iy = Year(date())
			
			bufferdays = 0



			sqlstring = "SELECT tr_effdate, tr_nbr, tr_line, tr_part, tr_per_date, - tr_qty_chg, tr_prod_line, " & _
					" (CASE WHEN tr_effdate <= tr_per_date THEN (- tr_qty_chg) ELSE 0 END) " & _
					" FROM PUB.tr_hist left join PUB.pl_mstr on tr_prod_line = pl_prod_line " & _
					" WHERE MONTH(tr_effdate) = " & im & " AND YEAR(tr_effdate) = " & iy & " AND tr_part <> '3TP400' AND tr_part <> '3TP600' AND " & _
					" tr_type = 'ISS-SO' AND tr_qty_req <> 0 AND (tr_um = 'EA' OR tr_um = '') " & _
					" ORDER BY tr_effdate, tr_nbr"




			set rs = Conn.Execute(sqlstring)
			if not rs.eof then mtdata = rs.getRows()
			rs.close



					
		'	set rs2 = Conn.Execute("select  " & _
		'		" tr_effdate, tr_nbr, tr_line, tr_part, tr_per_date, - tr_qty_chg, tr_prod_line, " & _
		'		" (if tr_effdate <= tr_per_date then (- tr_qty_chg) else 0) " & _
		'		"from tr_hist left join pl_mstr on tr_prod_line = pl_prod_line " & _
		'		" where month(tr_effdate) = " & im & " and year(tr_effdate) = " & iy & " and " & _
		'		" tr_type = ""ISS-SO"" and tr_qty_req <> 0  and (tr_um = ""EA"" or tr_um = """") and " & _
		'		" tr_part <> ""3TP400"" and tr_part <> ""3TP600"" " & _
		'		"order by tr_effdate, tr_nbr")
				'" tr_effdate), month(tr_effdate), " & _
				'" sum(if tr_effdate <= (tr_per_date + " & bufferdays & " ) then (- tr_qty_chg) else 0) / " & _
				'" (sum(if tr_effdate <= (tr_per_date + " & bufferdays & " ) then (- tr_qty_chg) else 0) + " & _
				'"  sum(if tr_effdate > (tr_per_date + " & bufferdays & " ) then (- tr_qty_chg) else 0)), " & _
				'" sum(- tr_qty_chg), "  & _
				'" sum(if tr_effdate <= (tr_per_date + " & bufferdays & " ) then (- tr_qty_chg) else 0) " & _
		'	mtdata = rs2.getRows()
		'	rs2.close
			
			Conn.Close
			set Conn = Nothing

		%>

		<table border="0" cellpadding="3" cellspacing="0" bordercolor="#000000" bordercolorlight="#000000" bordercolordark="#000000">
		  <tr>
			<td align="center" bgcolor="#FF0000"><b><font face="Arial" size="3">Date</font></b></td>
			<td align="center" bgcolor="#FF0000"><b><font face="Arial" size="3">Perform
			  Date</font></b></td>
			<td align="center" bgcolor="#FF0000"><b><font face="Arial" size="3">SO Nbr</font></b></td>
			<td align="center" bgcolor="#FF0000"><b><font face="Arial" size="3">Item</font></b></td>
			<td align="center" bgcolor="#FF0000"><b><font face="Arial" size="3">Qty Shipped</font></b></td>
			<td align="center" bgcolor="#FF0000"><b><font face="Arial" size="3"> On Time</font></b></td>
		  </tr>
		<%	totalqty = 0
			totalontime = 0
			for i = lbound(mtdata, 2) to ubound(mtdata, 2) 
				if CDate(mtData(0,i)) <= CDate(mtData(4,i)) then ontimeqty = CDbl(mtdata(5,i)) else ontimeqty = 0 %>
		  <tr <%if CDbl(mtData(5,i)) <> ontimeqty then%> style="background: rgb(255,0,0)"<%end if%>>
			<td><font face="Arial" size="3"><%=mtdata(0,i)%></font></td>
			<td><font face="Arial" size="3"><%=mtdata(4,i)%></font></td>
			<td><font face="Arial" size="3"><%=mtdata(1,i)%></font></td>
			<td><font face="Arial" size="3"><%=mtdata(3,i)%></font></td>
			<td align="right"><font face="Arial" size="3"><%=mtData(5,i)%></font></td>
			<td align="right"><font face="Arial" size="3"><%=ontimeqty%></font></td>
		  </tr>
		<%		totalqty = totalqty + CDbl(mtData(5,i))
				totalontime = totalontime + ontimeqty
			next 
		%>
		  <tr>
			<td bgcolor="#C0C0C0"><b><font face="Arial" size="3">Total</font></b></td>
			<td bgcolor="#C0C0C0">&nbsp;</td>
			<td bgcolor="#C0C0C0">&nbsp;</td>
			<td bgcolor="#C0C0C0">&nbsp;</td>
			<td bgcolor="#C0C0C0" align="right"><b><font face="Arial" size="3"><%=totalqty%></font></b></td>
			<td bgcolor="#C0C0C0" align="right"><b><font face="Arial" size="3"><%=formatNumber(totalontime / totalqty * 100, 2) & "%"%></font></b></td>
		  </tr>
		</table>
		<p>&nbsp;</p>
		<hr color="#FF0000">
		<p>&nbsp;</p>
		
			<script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
		<script type="text/javascript">
	      $(document).ready(function () {
	        $('#pageTitleDiv').html("");
	        $('#pageTitleDiv').html("<h5>On Time Shipment Report</h5>");
			$('#shortPageTitleDiv').html("");
			$('#shortPageTitleDiv').html("<h5>Sales</h5>");
	      })
	  </script>

	</body>
</html>