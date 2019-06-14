<%	Response.buffer = true
	Server.ScriptTimeout = 10000 
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
		<div class="all-gp-sloHeader" id="parentsHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->
		
		<%	
			Set Conn = Server.CreateObject("ADODB.Connection")
			Conn.ConnectionString = "DSN=SPG;UID=mfg;PWD="
			Conn.Open SPG
			set itemRS = Conn.Execute("Select pt_desc1, pt_desc2, pt_draw, pt_rev, pt_um from PUB.pt_mstr where pt_domain = 'SPG' and pt_part = '" & Request("item") & "'")
			if itemRS.eof then Response.Redirect "searchresults.asp?item=" & Server.URLEncode(Request("item")) & "&desc=" & Server.URLEncode(Request("desc")) & "&ret=parents.asp"
			um = CStr(itemRS("pt_um"))
			
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

		<h5>
			Parents of <a href="item.asp?item=<%=Server.URLEncode(request("item"))%>"><%=Request("item")%></a> <small><%=itemRS("pt_desc1") & " " & itemRS("pt_desc2") & "</small>"%> <%
			part = request("item")
			revision = itemRS("pt_rev")
			drawing = getDrawing(part, revision)
			Response.Write " <small><small>[ "
			if drawing <> "" then Response.Write "<a href=""/Department/doc_con/DWG/REL/" & drawing & """>Drawing</a> | "
			if Request("level") = "ALL" then 
				Response.Write "<a href=""parents.asp?item=" & Server.URLEncode(part) & """>1 Level Parents</a> ]</small></small>" & vbCrLf
			else
				Response.Write "<a href=""parents.asp?item=" & Server.URLEncode(part) & "&level=ALL"">All Parents</a> ]</small></small>" & vbCrLf
			end if
			%>
		</h5>
		<h6>Sorted by <%=sortby%> &nbsp;&nbsp;(Sort by <%=revsortby%>)</h6>
		<%
			itemRS.Close
			set itemRS = Nothing
			if Request("level") = "ALL" then
				getParents Request("item"), true
			else
				getParents Request("item"), false
			end if
		%>	
		</small>

		<form method="GET" action="searchresults.asp">
		  <div align="center">
			  <table border="2" cellpadding="4" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
				  <td>
					<div align="center">
						<strong>Item:</strong><input type="text" name="item" size="20" value="<%=Request("item")%>">
						<input type="submit" value="Submit" name="B1"><input type="reset" value="Reset" name="B2">
					</div>
				  </td>
				</tr>
			  </table>
		  </div>
			  <input type="hidden" name="ret" value="parents.asp">
		</form>
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
	Conn.Close	
	Set Conn = Nothing

	function getParents(child, multilevel)
		If not Response.IsClientConnected then exit function
		if sortby = "Item" then 
			orderby = "order by pt_mstr.pt_part"
		else
			orderby = "order by pt_mstr.pt_desc1, pt_mstr.pt_desc2" 
		end if
		
		set chRS = Conn.Execute("Select ps_par, ps_comp, ps_qty_per, pt_mstr.pt_desc1, pt_mstr.pt_desc2, ps_item_no, ps_ps_code, pt_mstr.pt_phantom, ptmstr.pt_um, pt_mstr.pt_rev " & _
				" from PUB.ps_mstr join PUB.pt_mstr on pt_mstr.pt_domain = ps_domain and pt_mstr.pt_part = ps_par " & _
				" join PUB.pt_mstr ptmstr on ptmstr.pt_domain = ps_domain and ptmstr.pt_part = ps_comp " & _
				" where ps_domain = 'SPG' and ps_comp = '" & child & "' and " & _
				" (ps_start <= curdate() or ps_start is null) and (ps_end >= curdate() or ps_end is null) " & orderby)
		if not chRS.eof then	
			Response.Write "<UL>" & vbCrLf
			haveList = true
		else
			haveList = false
		end if
		do while not chRS.eof
			curPar = chRS("ps_par")
			Response.Write "<LI><a href=""item.asp?item=" & Server.URLEncode(curPar) & """>" & chRS("ps_par") & "</a> <small>(" & chRS("ps_qty_per") & " " & chRS("pt_um") & ") " & _
				chRS("pt_desc1") & " " & chRS("pt_desc2") & "</small></LI>" & vbCrLf
			revision = chRS("pt_rev")
			drawing = getDrawing(curPar, revision)
			Response.Write " <small>[ "
			if drawing <> "" then Response.Write "<a href=""/Department/doc_con/DWG/REL/" & drawing & """>Drawing</a> | "
			Response.Write " <a href=""parents.asp?item=" & curPar & """>Parents</a> | " & _
							 " <a href=""prodstruct.asp?item=" & curPar & """>PS</a> ]</small>" & vbCrLf
			if multilevel then getParents curPar, true
			chRS.MoveNext
		Loop
		chRS.Close
		set chRS = Nothing
		if haveList then
			Response.Write "</UL>" & vbCrLf
		end if
	end function

	function getDrawing(item, rev)
		drawing = mid(item,1,2) + "\" & mid(item,3,3) + "\" & mid(item,6,2) & "___" & rev & ".pdf"
		set fs = Server.CreateObject("Scripting.FileSystemObject")
		if fs.FileExists("K:\Department\doc_con\DWG\REL\" & drawing) then
			getDrawing = replace(drawing, "\", "/")
		else
		drawing = mid(item,1,2) + "\" & mid(item,3,3) + "\" & mid(item,6,2) & "_" & rev & ".pdf"
		if fs.FileExists("K:\Department\doc_con\DWG\REL\" & drawing) then
			getDrawing = replace(drawing, "\", "/")
		else
			getDrawing = ""
		end if
	end if
	set fs = Nothing
	end function
%>