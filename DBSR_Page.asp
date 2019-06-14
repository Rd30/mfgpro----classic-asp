<html  xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
	<head>
		<!-- #include file = "../gp-slo/common/gp-sloHead.html" -->
	</head>
	<body>
		<!-- Dark overlay element -->
		<div class="overlay" id="dbsrOverlay"></div>

		<!--NavBar/Header-->
		<div class="all-gp-sloHeader" id="dbsrHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->
		<%
			
			country = Request("country")	
			im = Request("month")
			iy = Request("year")

			if iy = "" then
				iy = year(date)
			end if

			if im = "" then
				im = month(date)
			end if			

			if country = "" then
				country = "All/All Countries"
			end if
			
			labelCountryCode = Left(country,3)
			labelCountry = " (" & Mid(country,5) & ")"		

		'	Response.Write("iy - " & iy)
		'	Response.Write("im - " & im)


			if im = 13 then
				sdate = "1/1/" & iy
			else
				sdate = im & "/1/" & iy
			end if
				

		'	iday = Trim(DateAdd("d", -1, Str(im + 1) + "/01/" + Trim(Str(iy))))
		'	edate = im & "/" & iday & "/" & iy

			if im = 13 then
				if CInt(iy) < year(date) then
					edate = "12/31/" & iy
				else
					edate = CStr(CDate((month(date) + 1) & "/1/" & iy) - 1)	
				end if	
			else
				if im = 12 then 
					edate = "12/31/" & iy
				else
					edate = CStr(CDate((im + 1) & "/1/" & iy) - 1)
				end if	
			end if
			
		'	Response.Write("year(date) - " &  year(date))
		'	Response.Write("sdate - " & sdate)
		'	Response.Write("edate - " & edate)
			

			if CDate(edate) < date then
				flagPast = "Yes"
			else
				flagPast = "No"
			end if

		%>

		<p align="center"><strong><font face="Arial" size="4">&nbsp;&nbsp;&nbsp; Daily Booking and Shipping Report</font></strong></p>
		<p align="center"><strong><font face="Arial" size="4">&nbsp;&nbsp;&nbsp; Time Period: <%=sdate & " - " & edate & labelCountry %></font></strong></p>
		<div align="center">
		<table border="1" cellspacing="0" height="57">
		  <tr>
			<td colspan="2" valign="bottom"
			style="border-bottom-style: solid; border-bottom-width: 2; padding-bottom: 1" align="center" height="58" bgcolor="#99CCFF">
			  <p><b><font face="Arial" size="2">Product
			Line</font></b></p>
			</td>
			<center>

			<td valign="bottom" align="center"
			style="border-bottom-style: solid; border-bottom-width: 2; padding-bottom: 1" height="58" bgcolor="#99CCFF">
			<p><b><font face="Arial" size="2">M.T.D.<br>
			Bookings</font></b></td>
			<td valign="bottom" align="center"
			style="border-bottom-style: solid; border-bottom-width: 2; padding-bottom: 1" height="58" bgcolor="#99CCFF">
			<p><b><font face="Arial" size="2">M.T.D.<br>
			Shipments</font></b></td>
			<td valign="bottom" align="center"
			style="border-bottom-style: solid; border-bottom-width: 2; padding-bottom: 1" height="58" bgcolor="#99CCFF">
			<p><b><font face="Arial" size="2">Backlog</font></b></td>
			<td valign="bottom" align="center"
			style="border-bottom-style: solid; border-bottom-width: 2; padding-bottom: 1" height="58" bgcolor="#99CCFF">
			<p><b><font face="Arial" size="2">Monthly<br>
			Shipment<br>
			Forecast</font></b></td>
			<td valign="bottom" align="center"
			style="border-bottom-style: solid; border-bottom-width: 2; padding-bottom: 1" height="58" bgcolor="#99CCFF">
			<p><b><font face="Arial" size="2">Total Orders<br>In Hand<br>
			(As of Today)</font></b></td>
		  </tr>
		<%	
			
			Set Conn = Server.CreateObject("ADODB.Connection")
			SPG = "DSN=SPG;UID=mfg;PWD="
			Conn.Open SPG

			dim tableCountry
			sql = "SELECT country, ctry_country " & _
				  "FROM (SELECT DISTINCT ad_ctry AS country " & _
				  "FROM PUB.ls_mstr left outer join PUB.ad_mstr " & _
				  "ON  ad_domain = ls_domain " & _
				  "AND ad_addr   = ls_addr " & _
				  "WHERE ls_domain = 'SPG' " & _
				  "AND (ls_type = 'customer' OR ls_type = 'ship-to') " & _
				  "AND ad_ctry <> '') AS shipAddress " & _
				  "inner join PUB.ctry_mstr ON country = ctry_ctry_code " & _
				  "ORDER BY ctry_country "

			set rs = Conn.Execute(sql)
			if not rs.eof then tableCountry = rs.getRows()
			rs.Close
			Set rs = Nothing
					  

			dim pls
			sql = "SELECT pl_prod_line, pl_desc, 0, 0, 0, 0, 0 " & _
					   "FROM PUB.pl_mstr where pl_domain = 'SPG' order by pl_prod_line"
			set rs = Conn.Execute(sql)
			pls = rs.getRows()
			'redim preserve pls (ubound(pls, 1), ubound(pls, 2) + 1) 
			'Response.Write "<" & "!--numrows=" & ubound(pls,2) & "-->" & vbCrLf


				sql = "SELECT ad_ctry, upper(tr_prod_line), " & _
					"sum(case tr_type when 'ORD-SO' then tr_qty_req * tr_price else 0 end), " & _
					"sum(case when tr_type <> 'ORD-SO' then (- tr_qty_loc) * tr_price else 0 end) " & _
					"FROM (PUB.tr_hist LEFT OUTER JOIN " & _
					"(SELECT order_num AS orderNum, min(ship_to) AS shipTo " & _
					"FROM (SELECT so_nbr AS order_num, so_ship AS ship_to " & _
					"FROM PUB.so_mstr WHERE so_domain = 'SPG' " & _
					"UNION " & _
					"SELECT ih_nbr AS order_num, ih_ship AS ship_to " & _
					"FROM PUB.ih_hist WHERE ih_domain = 'SPG' " & _
					"AND ih_inv_date >= '" & sdate & "' " & _
					") AS CombinedSoIh " & _
					"GROUP By order_num " & _
					") AS Orders " & _
					"ON tr_nbr = orderNum " & _
					"LEFT OUTER JOIN PUB.ad_mstr ON ad_domain = 'SPG' " & _
					"AND ad_addr = shipTo " & _
					") " & _
					"WHERE tr_domain = 'SPG' AND tr_effdate >= '" & sdate & "' " & _
					"AND tr_effdate <= '" & edate & "' " & _
					"AND (tr_type = 'ORD-SO' OR tr_type = 'ISS-SO' OR tr_type = 'RCT-SOR') " & _
					"AND tr_prod_line <> '' " & _
					"GROUP BY ad_ctry, tr_prod_line ORDER BY ad_ctry, tr_prod_line"
						
			set rs = Conn.Execute(sql) 
			if not rs.eof then data = rs.getRows()
			rs.Close
			Set rs = Nothing
			textCountryParam = Left(country,3)
			if isArray(data) then
				for i = lbound(data,2) to ubound(data,2)
					foundRow = false
					for j = lbound(pls,2) to ubound(pls,2)
						if (CStr(pls(0,j)) = CStr(data(1,i))) AND ((data(0,i) = textCountryParam) OR (textCountryParam = "All")) then
							foundRow = true
							'Bookings
							pls(2,j) = Ccur(pls(2,j)) + Ccur(data(2,i))
							'Shipments
							pls(3,j) = Ccur(pls(3,j)) + Ccur(data(3,i))
							'Monthly Forecast
							pls(5,j) = Ccur(pls(5,j)) + Ccur(data(3,i))
						end if
						if foundRow then exit for
					Next
				Next
			end if
			
			textCountryParam = Left(country,3)
			sql = "select sod_cc, sum(sod_price * (sod_qty_ord - sod_qty_ship)), " & _
				"sum(case when (sod_due_date >= '" & sdate & "' AND sod_due_date <= '" & edate & "') " & _
							 "then sod_price * (sod_qty_ord - sod_qty_ship) " & _
						  "else 0 end) " & _
				"from PUB.sod_det inner join PUB.pl_mstr on pl_domain = sod_domain and pl_prod_line = sod_cc " & _
				"inner join PUB.so_mstr on so_domain = sod_domain and so_nbr = sod_nbr " & _
				"inner join PUB.ad_mstr on ad_domain = so_domain and ad_addr = so_ship " & _
							   "and (ad_ctry = '" & textCountryParam & "' or " & _
							"'" & textCountryParam & "' = 'All') " & _
					"where sod_domain = 'SPG' group by sod_cc"

			set rs = Conn.Execute(sql)
			data = rs.getRows()
			rs.Close
			set rs = Nothing
			for i = lbound(data,2) to ubound(data,2)
				foundRow = false
				for j = lbound(pls,2) to ubound(pls,2)
					if CStr(pls(0,j)) = CStr(data(0,i)) then
						foundRow = true
						'Orders in hand
						pls(6,j) = Ccur(pls(6,j)) + Ccur(data(1,i))
						'Backlog
						pls(4,j) = Ccur(pls(4,j)) + Ccur(data(2,i))
						'Monthly Forecast
						pls(5,j) = Ccur(pls(5,j)) + Ccur(data(2,i))
					end if
					if foundRow then exit for
				next
			next
			
			set data2 = Nothing
			
			poubookings = 0
			QEsubtotal = array("","Small Purifier Subtotal (QE)", 0, 0, 0, 0, 0)
			QEfound = false
			QKsubtotal = array("","Large Purifier Subtotal (QK)", 0, 0, 0, 0, 0)
			QKfound = false
			QNsubtotal = array("","Customer Service Subtotal (QN)", 0, 0, 0, 0, 0)
			QNfound = false
			QSsubtotal = array("","Palladium Purifier Subtotal (QS)", 0, 0, 0, 0, 0)
			QSfound = false

			for i = lbound(pls,2) to ubound(pls,2)
				   ' Track and Print QE sub-totals
				if left(pls(0,i),2) = "QE" then
				   for j = 2 to ubound(pls,1)
					  QEsubtotal(j) = QEsubtotal(j) + pls(j,i)
					  if pls(j,i) <> 0 then
						 QEfound = true
					  end if
				   next
				end if
				if QEfound = true and left(pls(0,i),2) <> "QE" then
				   origBgColor = bgcolor
				   bgcolor = "bgcolor=""#99CCFF"""
		%>
		  <tr <%=bgcolor%>>
			<td></td>
			<td valign="bottom" align="center" height="1"><font face="Arial"><%=QEsubtotal(1)%> </font>  </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QEsubtotal(2) <> 0 then Response.Write formatCurrency(QEsubtotal(2), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QEsubtotal(3) <> 0 then Response.Write formatCurrency(QEsubtotal(3), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QEsubtotal(4) <> 0 then Response.Write formatCurrency(QEsubtotal(4), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QEsubtotal(5) <> 0 then Response.Write formatCurrency(QEsubtotal(5), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else if QEsubtotal(6) <> 0 then Response.Write formatCurrency(QEsubtotal(6), 0) else Response.Write "&nbsp;" end if end if %> </font> </td>
		  </tr>
		<%         QEfound = false
				   bgcolor = origBgColor
				end if

				   ' Track and Print QK sub-totals
				if left(pls(0,i),2) = "QK" then
				   for j = 2 to ubound(pls,1)
					  QKsubtotal(j) = QKsubtotal(j) + pls(j,i)
					  if pls(j,i) <> 0 then
						 QKfound = true
					  end if
				   next
				end if
				if QKfound = true and left(pls(0,i),2) <> "QK" then
				   origBgColor = bgcolor
				   bgcolor = "bgcolor=""#99CCFF"""
		%>
		  <tr <%=bgcolor%>>
			<td></td>
			<td valign="bottom" align="center" height="1"><font face="Arial"><%=QKsubtotal(1)%> </font>  </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QKsubtotal(2) <> 0 then Response.Write formatCurrency(QKsubtotal(2), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QKsubtotal(3) <> 0 then Response.Write formatCurrency(QKsubtotal(3), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QKsubtotal(4) <> 0 then Response.Write formatCurrency(QKsubtotal(4), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QKsubtotal(5) <> 0 then Response.Write formatCurrency(QKsubtotal(5), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else if QKsubtotal(6) <> 0 then Response.Write formatCurrency(QKsubtotal(6), 0) else Response.Write "&nbsp;" end if end if %> </font> </td>
		  </tr>
		<%         QKfound = false
				   bgcolor = origBgColor
				end if

				   ' Track and Print QN sub-totals
				if left(pls(0,i),2) = "QN" then
				   for j = 2 to ubound(pls,1)
					  QNsubtotal(j) = QNsubtotal(j) + pls(j,i)
					  if pls(j,i) <> 0 then
						 QNfound = true
					  end if
				   next
				end if
				if QNfound = true and left(pls(0,i),2) <> "QN" then
				   origBgColor = bgcolor
				   bgcolor = "bgcolor=""#99CCFF"""
		%>
		  <tr <%=bgcolor%>>
			<td></td>
			<td valign="bottom" align="center" height="1"><font face="Arial"><%=QNsubtotal(1)%> </font>  </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QNsubtotal(2) <> 0 then Response.Write formatCurrency(QNsubtotal(2), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QNsubtotal(3) <> 0 then Response.Write formatCurrency(QNsubtotal(3), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QNsubtotal(4) <> 0 then Response.Write formatCurrency(QNsubtotal(4), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QNsubtotal(5) <> 0 then Response.Write formatCurrency(QNsubtotal(5), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else if QNsubtotal(6) <> 0 then Response.Write formatCurrency(QNsubtotal(6), 0) else Response.Write "&nbsp;" end if end if %> </font> </td>
		  </tr>
		<%         QNfound = false
				   bgcolor = origBgColor
				end if


				   ' Track and Print QS sub-totals
				if left(pls(0,i),2) = "QS" then
				   for j = 2 to ubound(pls,1)
					  QSsubtotal(j) = QSsubtotal(j) + pls(j,i)
					  if pls(j,i) <> 0 then
						 QSfound = true
					  end if
				   next
				end if
				if QSfound = true and left(pls(0,i),2) <> "QS" then
				   origBgColor = bgcolor
				   bgcolor = "bgcolor=""#99CCFF"""
		%>
		  <tr <%=bgcolor%>>
			<td></td>
			<td valign="bottom" align="center" height="1"><font face="Arial"><%=QSsubtotal(1)%> </font>  </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(2) <> 0 then Response.Write formatCurrency(QSsubtotal(2), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(3) <> 0 then Response.Write formatCurrency(QSsubtotal(3), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(4) <> 0 then Response.Write formatCurrency(QSsubtotal(4), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(5) <> 0 then Response.Write formatCurrency(QSsubtotal(5), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else if QSsubtotal(6) <> 0 then Response.Write formatCurrency(QSsubtotal(6), 0) else Response.Write "&nbsp;" end if end if %> </font> </td>
		  </tr>
		<%         QSfound = false
				   bgcolor = origBgColor
				end if
				   ' Only print active (non-zero) product lines'
				rowAllZero = true
				for j = 2 to ubound(pls,1)
				   if pls(j,i) <> 0 then
					  rowAllZero = false
					  exit for
				   end if
				next
				if rowAllZero = false then
				   if bgcolor = "" then bgcolor = "bgcolor=""#dddddd""" else bgcolor = ""
		%>
		  <tr <%=bgcolor%>>
			<td valign="bottom" height="1"><font face="Arial"><%=pls(0,i)%> </font> </td>
			<td valign="bottom" height="1"><font face="Arial"><%=pls(1,i)%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if pls(2,i) <> 0 then Response.Write formatCurrency(pls(2,i), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if pls(3,i) <> 0 then Response.Write formatCurrency(pls(3,i), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if pls(4,i) <> 0 then Response.Write formatCurrency(pls(4,i), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if pls(5,i) <> 0 then Response.Write formatCurrency(pls(5,i), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else if pls(6,i) <> 0 then Response.Write formatCurrency(pls(6,i), 0) else Response.Write "&nbsp;" end if end if %> </font> </td>
		  </tr>
		<%		   bookingtotal = bookingtotal + pls(2,i)
				   shipmenttotal = shipmenttotal + pls(3,i)
				   backlogtotal = backlogtotal + pls(4,i)
				   forecasttotal = forecasttotal + pls(5,i)
				   orderstotal = orderstotal + pls(6,i)
				   if pls(0,i) >= "QE10" and pls(0,i) <= "QE50" then
					   poubookings = poubookings + pls(2,i)
				   end if
				end if
			next 

			   ' If "QS" is last group, must test before totals
			if QSfound = true then
			   origBgColor = bgcolor
			   bgcolor = "bgcolor=""#99CCFF"""
		%>
		  <tr <%=bgcolor%>>
			<td></td>
			<td valign="bottom" align="center" height="1"><font face="Arial"><%=QSsubtotal(1)%> </font>  </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(2) <> 0 then Response.Write formatCurrency(QSsubtotal(2), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(3) <> 0 then Response.Write formatCurrency(QSsubtotal(3), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(4) <> 0 then Response.Write formatCurrency(QSsubtotal(4), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><%if QSsubtotal(5) <> 0 then Response.Write formatCurrency(QSsubtotal(5), 0) else Response.Write "&nbsp;"%> </font> </td>
			<td valign="bottom" align="right" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else if QSsubtotal(6) <> 0 then Response.Write formatCurrency(QSsubtotal(6), 0) else Response.Write "&nbsp;" end if end if %> </font> </td>
		  </tr>
		<%      QSfound = false
				bgcolor = origBgColor
			end if
		%>
		  <tr>
			<td valign="bottom" height="1"> </td>
			<td valign="bottom" height="2"> <font face="Arial" size="2"><b>TOTAL</b></font></td>
			<td valign="bottom" align="right" style="padding-top: 1" height="1"><font face="Arial"><%=formatCurrency(bookingtotal, 0)%> </font> </td>
			<td valign="bottom" align="right" style="padding-top: 1" height="1"><font face="Arial"><%=formatCurrency(shipmenttotal, 0)%> </font> </td>
			<td valign="bottom" align="right" style="padding-top: 1" height="1"><font face="Arial"><%=formatCurrency(backlogtotal, 0)%> </font> </td>
			<td valign="bottom" align="right" style="padding-top: 1" height="1"><font face="Arial"><%=formatCurrency(forecasttotal, 0)%> </font> </td>
			<td valign="bottom" align="right" style="padding-top: 1" height="1"><font face="Arial"><% if flagPast = "Yes" then Response.Write "&nbsp;" else Response.Write formatCurrency(orderstotal, 0) end if%> </font> </td>
		  </tr>
		</table>
		</div>

		<font face="Arial"><%=now & " " & date%></font>

		<br>
		<p>
		<form  method="GET" action="DBSR_Page.asp">
		Country
		<select id="Select3" name="country">
			<option value="All/All Countries">All Countries</option>
		<%	if isArray(tableCountry) then
				for i = lbound(tableCountry,2) to ubound(tableCountry,2)%>

		<option value="<%=tableCountry(0,i) & "/" & tableCountry(1,i)%>" <%if country=tableCountry(0,i) & "/" & tableCountry(1,i) then %>selected<% end if %>><%=tableCountry(1,i)%></option>

		<%      Next
			end if%>
		</select>

		&nbsp;&nbsp;
		Year
		<select id="select2" name="year">
		<%currentYear = year(date) + 1
		while currentYear > 1995%>

		<option value="<%=currentYear%>"<%if CStr(iy)=CStr(currentYear) then %>selected<% end if %>><%=currentYear%></option>

		<%currentYear = currentYear - 1
		Wend%>
		</select>
		&nbsp;&nbsp;
		Month 
		<select id="select1" name="month">
		  <option value="1"<%if im=1 then %>selected<% end if %>>1</option>
		  <option value="2"<%if im=2 then %>selected<% end if %>>2</option>
		  <option value="3"<%if im=3 then %>selected<% end if %>>3</option>
		  <option value="4"<%if im=4 then %>selected<% end if %>>4</option>
		  <option value="5"<%if im=5 then %>selected<% end if %>>5</option>
		  <option value="6"<%if im=6 then %>selected<% end if %>>6</option>
		  <option value="7"<%if im=7 then %>selected<% end if %>>7</option>
		  <option value="8"<%if im=8 then %>selected<% end if %>>8</option>
		  <option value="9"<%if im=9 then %>selected<% end if %>>9</option>
		  <option value="10"<%if im=10 then %>selected<% end if %>>10</option>
		  <option value="11"<%if im=11 then %>selected<% end if %>>11</option>
		  <option value="12"<%if im=12 then %>selected<% end if %>>12</option>
		  <option value="13"<%if im=13 then %>selected<% end if %>>All Months (YTD)</option>
		</select>

		<input type="submit" value="Go" ID="Submit1" NAME="Submit1">
		</form>
		</p>

		<hr color="#FF0000">

		<p align="center"><strong><font face="Arial" size="4">Current Backlog By Month:</font></strong></p>
		<%
			textCountryParam = Left(country,3)
			sql = "select month(sod_due_date), year(sod_due_date), " & _
				"sum(sod_price * (sod_qty_ord - sod_qty_ship)) " & _
				"from PUB.sod_det inner join PUB.pl_mstr on pl_domain = sod_domain and pl_prod_line = sod_cc " & _
				"left outer join (SELECT so_domain AS orderDomain, " & _
				"so_nbr AS orderNum, " & _
				"ad_ctry AS shipCountry " & _
				"FROM PUB.so_mstr left outer join PUB.ad_mstr " & _
				"ON ad_domain = so_domain AND ad_addr = so_ship) " & _
				"AS order ON orderDomain = sod_domain AND orderNum = sod_nbr " & _
				"where sod_domain = 'SPG' " & _
				"and sod_due_date >= '" & Month(date()) & "/1/" & Year(date()) & "'" & _
				"and sod_due_date <= '" & Cstr(date() + 365) & "' " & _
				"and (shipCountry = '" & textCountryParam & "' " & _
				"or '" & textCountryParam & "' = 'All') " & _
				"group by year(sod_due_date), month(sod_due_date) " & _
				"order by year(sod_due_date), month(sod_due_date) "

			Response.Write "<" & "!--" & sql & "-->" & vbCrlF
			set rs = Conn.Execute(sql)
		%>

		<table border="1">
		<%	do while not rs.eof %>
		  <tr>
			<td align="right"><font face="Arial"><%=rs(0) & "/" & rs(1)%>
			  </font>
			&nbsp;</td>
			<td align="right"><font face="Arial"><%="$" & formatNumber(rs(2), "0,000")%>
			  </font>
		   &nbsp;</td>
		  </tr>
		<%		rs.MoveNext
			Loop
			rs.close
			set rs = Nothing
		%>
		</table>
		<%
			Conn.Close
			Set Conn = Nothing
		%>

		<hr color="#FF0000">

		<p align="center"><strong><font face="Arial" size="4">Recent Bookings Of Note:</font></strong></p>

		<table border="1" cellpadding="0" cellspacing="0" style="border-collapse: collapse; font-family:Arial; font-size:10pt" bordercolor="#111111" width="800" id="AutoNumber13" height="63" >
		  <tr>
			<td width="63" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; border-bottom-style: solid; border-bottom-width: 1" align="left" height="1" bgcolor="#99CCFF">
			<p align="center">
			<font face="Arial">Date</font></td>
			<td width="65" align="left" height="1" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; ; border-bottom-style:solid; border-bottom-width:1" bgcolor="#99CCFF">
			<p align="center"><b><font face="Arial">SO#</font></b></td>
			<td width="52" align="left" height="1" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; ; border-bottom-style:solid; border-bottom-width:1" bgcolor="#99CCFF">
			<p align="center">
			<b><font face="Arial">Qty</font></b></td>
			<td width="228" align="left" height="1" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; ; border-bottom-style:solid; border-bottom-width:1" bgcolor="#99CCFF">
			<p align="center">
			<b><font face="Arial">Item</font></b></td>
			<td width="207" align="left" height="1" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; ; border-bottom-style:solid; border-bottom-width:1" bgcolor="#99CCFF">
			<p align="center">
			<b><font face="Arial">Sold To:</font></b></td>
			<td width="220" align="left" height="1" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; ; border-bottom-style:solid; border-bottom-width:1" bgcolor="#99CCFF">
			<p align="center">
			<b><font face="Arial">Ship To:</font></b></td>
			<td width="107" align="right" height="1" style="border-left-style: solid; border-left-width: 1; border-right-style: solid; border-right-width: 1; border-top: 1px solid #111111; ; border-bottom-style:solid; border-bottom-width:1" bgcolor="#99CCFF">
			<p align="center">
			<b><font face="Arial">Extended Price (USD)</font></b></td>
		  </tr>

		  <tr>
			<td width="63" style="border-style:solid; border-width:1" align="left" height="31">
			&nbsp;</td>
			<td width="65" height="31" style="border-style:solid; border-width:1; " class="style1">
			&nbsp;</td>
			<td width="52" align="center" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="228" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="207" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="220" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="107" align="right" height="31" style="border-left-style: solid; border-left-width: 1; border-right: 1px solid #111111; border-top-style:solid; border-top-width:1; border-bottom-style:solid; border-bottom-width:1">
			&nbsp;</td>
		  </tr>
				  
		  <tr>
			<td width="63" style="border-style:solid; border-width:1" align="left" height="31">
			&nbsp;</td>
			<td width="65" height="31" style="border-style:solid; border-width:1; " class="style1">
			&nbsp;</td>
			<td width="52" align="center" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="228" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="207" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="220" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="107" align="right" height="31" style="border-left-style: solid; border-left-width: 1; border-right: 1px solid #111111; border-top-style:solid; border-top-width:1; border-bottom-style:solid; border-bottom-width:1">
			&nbsp;</td>
		  </tr>
				  
		  <tr>
			<td width="63" style="border-style:solid; border-width:1" align="left" height="31">
			&nbsp;</td>
			<td width="65" height="31" style="border-style:solid; border-width:1; " class="style1">
			&nbsp;</td>
			<td width="52" align="center" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="228" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="207" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="220" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="107" align="right" height="31" style="border-left-style: solid; border-left-width: 1; border-right: 1px solid #111111; border-top-style:solid; border-top-width:1; border-bottom-style:solid; border-bottom-width:1">
			&nbsp;</td>
		  </tr>
				  
		  <tr>
			<td width="63" style="border-style:solid; border-width:1" align="left" height="31">
			&nbsp;</td>
			<td width="65" height="31" style="border-style:solid; border-width:1; " class="style1">
			&nbsp;</td>
			<td width="52" align="center" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="228" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="207" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="220" align="left" height="31" style="border-style:solid; border-width:1; ">
			&nbsp;</td>
			<td width="107" align="right" height="31" style="border-left-style: solid; border-left-width: 1; border-right: 1px solid #111111; border-top-style:solid; border-top-width:1; border-bottom-style:solid; border-bottom-width:1">
			&nbsp;</td>
		  </tr>
				  
		  </table>

		<hr color="#FF0000">

		<p>&nbsp;</p>

		<p align="center"><strong><font face="Arial" size="4">Booking Estimate:</font></strong></p>

		<table border="1" width="571">
		  <tr>
			<td width="291" valign="middle" nowrap align="center" bgcolor="#99CCFF">
			<p align="center"><strong><font face="Arial" size="2">Description:</font></strong></td>
			<td width="84" align="center" valign="middle" nowrap bgcolor="#99CCFF"><p align="center"><strong><font face="Arial" size="2">Amount:</font></strong></td>
			<td width="187" align="center" valign="middle" nowrap bgcolor="#99CCFF"><p align="center"><strong><font face="Arial" size="2">Current
			Status:</font></strong></td>
		  </tr>
		  <tr>
			<td width="291" valign="middle" nowrap align="center">
			<p align="center"><font face="Arial" size="2">POU Purifiers</font></td>
			<td width="84" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
			<td width="187" align="center" valign="middle" nowrap>
			<p align="center"><font face="Arial" size="2">MTD Booked:&nbsp;$<%=formatNumber(poubookings, 0)%></font></td>
		  </tr>
		  <tr>
			<td width="291" valign="middle" nowrap align="center">
			<p align="center">&nbsp;</td>
			<td width="84" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
			<td width="187" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
		  </tr>
		  <tr>
			<td width="291" valign="middle" nowrap align="center">
			<p align="center">&nbsp;</td>
			<td width="84" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
			<td width="187" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
		  </tr>
		  <tr>
			<td width="291" valign="middle" nowrap align="center">
			<p align="center">&nbsp;</td>
			<td width="84" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
			<td width="187" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
		  </tr>
		  <tr>
			<td width="291" valign="middle" nowrap align="center">
			<p align="center"><b><font face="Arial" size="2">TOTAL</font></b></td>
			<td width="84" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
			<td width="187" align="center" valign="middle" nowrap>
			<p align="center">&nbsp;</td>
		  </tr>
		</table>

		<hr color="#FF0000">

		<p align="center"><strong><font face="Arial" size="4">Notes:</font></strong></p>

		<p align="center"><font face="Arial"><img src="../gp-slo/img/WB01512_.gif" alt="Note" align="bottom" width="30" height="17">&nbsp;<font size="2"><b>&nbsp;&nbsp; </b></font></font> </p>

		<hr color="#FF0000">

		<h6 align="center"><font face="Arial"><strong><font size="4">Archives</font></strong></font></h6>

		<table border="0" cellpadding="0" cellspacing="0" style="width:680" class="style2">
		  <colgroup>
			<col width="111" style="width: 83pt"><col width="111" style="width: 83pt">
			<col width="111" span="4" style="width: 83pt">
		  </colgroup>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; width: 107; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2001</font></td>
			<td style="width: 108; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2002</font></td>
			<td style="width: 108; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2003</font></td>
			<td style="width: 108; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2004</font></td>
			<td style="width: 108; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2005</font></td>
			<td style="width: 108; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2006</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2007</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2008</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2009</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2010</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2011</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2012</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2013</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2014</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2015</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2016</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2017</font></td>
			<td style="width: 105; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: .5pt solid windowtext; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px; background: #99CCFF" x:num>
			<font size="4">2018</font></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="http://SLO-FS01.entegris.com/Groups/Sales/DBSR/DBSR%20End%20Of%20Month%202001/01-JAN-2001.pdf">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/01-JAN-2002.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/01-JAN-2003.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/Jan04-DBSR.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/january.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/january.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/January.docx">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/January.doc">January</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/January%202018.docx">January</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/02-FEB-2001.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/02-FEB-2002.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/02-FEB-2003.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/February04-DBSR.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/february.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/February.docx">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/February.docx">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/February.doc">February</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/FEBRUARY%202018.docx">February</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/03-MAR-2001.pdf">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/03-MAR-2002.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/03-MAR-2003.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/Mar04-DBSR.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/march.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/March.doc">March</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/March%202018.docx">March</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/04-APR-2001.pdf">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/04-APR-2002.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/04-APR-2003%20.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/Apr04-DBSR.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/april.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/April.doc">April</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/April%202018.docx">April</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/05-MAY-2001.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/05-MAY-2002.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/05-May-03.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/May04-DBSR.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/may.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/May.doc">May</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/May%202018.docx">May</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/06-JUN-2001.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/06-JUN-2002.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/06-June-2003.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/June04-DBSR.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/june.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/June.doc">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/June.docx">June</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/June%202018.docx">June</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/07-JUL-2001.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/07-JUL-2002.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/07-July-2003.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/July04-DBSR.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/july.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/July.doc">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/July.docx">July</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/July%202018.docx">July</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/08-AUG-2001.pdf">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/08-AUG-2002.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/08-August-2003.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/Aug04-DBSR.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/august.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/august.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/august.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/august.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/august.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/August.doc">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/August.docx">August</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/August%202018.docx">August</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/09-SEP-2001.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/09-SEP-2002.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/09-Sept-2003.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/Sept04-DBSR.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/September.docx">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/September.doc">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/September.docx">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/September.docx">September</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2018/September%202018.docx">September</a></td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/10-OCT-2001.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/10-OCT-2002.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/10-October-2003.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/Oct04-DBSR.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/Oct.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/October.doc">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/October%20.docx">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/October.docx">October</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			October</td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			October</td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/11-NOV-2001.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/11-NOV-2002.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/11-November-2003.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/NOV04-DBSR.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/nov.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/November.doc">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/November.docx">November</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			November</td>
		  </tr>
		  <tr height="17" style="height:12.75pt">
			<td height="17" style="height: 12.75pt; text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: .5pt solid windowtext; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="107">
			<a href="DBSR%20End%20Of%20Month%202001/12-DEC-2001.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202002/12-DEC-2002.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202003/12-December-2003.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="DBSR%20End%20Of%20Month%202004/DEC04-DBSR.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2005/dec.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="108">
			<a href="EOM2006/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2007/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2008/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2009/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2010/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2011/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2012/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2013/DECEMBER.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2014/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2015/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2016/December.doc">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			<a href="EOM2017/December.docx">December</a></td>
			<td style="text-align: center; color: windowtext; font-size: 10.0pt; font-weight: 400; font-style: normal; text-decoration: none; font-family: Arial; vertical-align: bottom; white-space: nowrap; border-left: medium none; border-right: .5pt solid windowtext; border-top: medium none; border-bottom: .5pt solid windowtext; padding-left: 1px; padding-right: 1px; padding-top: 1px" width="105">
			December</td>
		  </tr>
		</table>
		
		<script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
		<script type="text/javascript">
	      $(document).ready(function () {
	        $('#pageTitleDiv').html("");
	        $('#pageTitleDiv').html("<h5>DBSR</h5>");
			$('#shortPageTitleDiv').html("");
			$('#shortPageTitleDiv').html("<h5>Sales</h5>");
	      })
		</script>

	</body>
</html>