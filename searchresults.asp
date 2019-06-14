<%	Response.Buffer = true
	Server.ScriptTimeout = 100000 
	Set Conn = Server.CreateObject("ADODB.Connection")
    conn.ConnectionString = "DSN=SPG;UID=mfg;PWD="	
	Conn.Open
%>
<%	pageTitle = "Results of search for "
		if Request("item") <> "" then
			 pageTitle = pageTitle & "&lt;ITEM&gt;=*" & Request("item") & "*"
		elseif Request("desc") <> "" then
			pageTitle = pageTitle & "&lt;DESCRIPTION&gt;=*" & Request("desc") & "*"
		end if
		if LCase(Request("sortby")) = "item" then
			sortby = "Item"
			revsortby = "<a href=""?item=" & Server.HTMLEncode(Server.URLEncode(Request("item"))) & _
				 "&desc=" &  Server.HTMLEncode(Server.URLENcode(Request("desc"))) & _
				 "&ret=" & Request("ret") & "&sortby=description" & """>Description</a>"
		else
			sortby = "Description"
			revsortby = "<a href=""?item=" & Server.HTMLEncode(Server.URLEncode(Request("item"))) & _
				 "&desc=" &  Server.HTMLEncode(Server.URLENcode(Request("desc"))) & _
				 "&ret=" & Request("ret") &  "&sortby=item" & """>Item</a>"
		end if
%>

<!DOCTYPE html>
<html lang="en-us">	
	<head>
		<!-- #include file = "../gp-slo/common/gp-sloHead.html" -->
	</head>
	<body class="mfgproBody">
		<!-- Dark overlay element -->
		<div class="overlay" id="overlay"></div>

		<!--NavBar/Header-->
		<div class="all-gp-sloHeader" id="itemHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->
		
		<h5>Sorted by <%=sortby%> &nbsp;&nbsp;(Sort by <%=revsortby%>)</h5>
		<%
			if sortby = "Item" then orderby = "pt_part" else orderby = "pt_desc1, pt_desc2"
			set itemRS = Conn.Execute("select pt_part, pt_desc1, pt_desc2 from PUB.pt_mstr where pt_domain = 'SPG' and " & _
				" pt_part like '%" & Request("item") & "%' and (pt_desc1 + pt_desc2) like '%" & Request("desc") & "%' " & _
				" order by " + orderby)
		%>
		<table class="list srchResTable" border="0">
			<%	numresults = 0
				do while not itemRS.eof
			%> 
			<tr>
			  <td><%="<a href=""" & Request("ret") & "?item=" & Server.URLEncode(itemRS("pt_part")) & """>" & Server.HTMLEncode(itemRS("pt_part")) & "</a>"%></td>
			  <td><%=itemRS("pt_desc1") & " " & itemRS("pt_desc2")%></td>
			</tr>
			<%
					retitem = itemRS("pt_part")
					numresults = numresults + 1
					if not Response.IsClientConnected then exit do
					itemRS.MoveNext
				Loop
				itemRS.Close
				set itemRS = Nothing
			%>
		</table>		
		</small>
		<br>
		<form method="GET" action="searchresults.asp">
			<input type="hidden" name="ret" value="<%=Request("ret")%>">
			<div align="center">
				<table border="2" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
					<tr>
					  <td>
						<div align="center">
							<strong>Item:</strong>
							<input type="text" name="item" size="20" value="<%=Request("item")%>">
							<input type="submit" value="Submit" name="B1"><input type="reset" value="Reset" name="B2">
						</div>	
					  </td>
					</tr>
				</table>
			</div>
		</form>
		<br>
		<script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
		<script type="text/javascript">
			$(document).ready(function () {
			  $('#pageTitleDiv').html("");
			  $('#pageTitleDiv').html("<h5>MFGPRO</h5>");
			  $('#shortPageTitleDiv').html("");
			  $('#shortPageTitleDiv').html("<h5>MFGPRO</h5>");
			})
		</script>	
	</body>
</html>
<%
	if numresults = 1 then response.redirect request("ret") & "?item=" & Server.URLEncode(retitem)
%>