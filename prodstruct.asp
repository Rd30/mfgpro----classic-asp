<%
	Response.Buffer = True
	Server.ScriptTimeout = 100000
	Set Conn = Server.CreateObject("ADODB.Connection")
	conn.ConnectionString = "DSN=SPG;UID=mfg;PWD="
	Conn.Open

	set itemRS = Conn.Execute("Select pt_desc1, pt_desc2, pt_draw, pt_rev from PUB.pt_mstr where pt_domain = 'SPG' and pt_part = '" & Request("item") & "'")
	myredir = "searchresults.asp?item=" & Server.URLEncode(Request("item")) & "&desc=" & Server.URLEncode(Request("desc")) & "&ret=prodstruct.asp"

	if itemRS.eof then Response.Redirect  myredir
%>
<%
	if lcase(request("c")) = "y" then levels = "Exploded" else levels = "Single Level"
	pageTitle = levels & " Product Structure for " & Request("item")
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
		<div class="all-gp-sloHeader" id="prodstructHeader"><!-- #include file = "../gp-slo/common/gp-sloHeader.html" --></div>

		<!--SideBar-->
		<!-- #include file = "../gp-slo/common/gp-sloSidebar.html" -->

		<h5><%=pageTitle%></h5>
		<h5>
			<a href="item.asp?item=<%=Server.URLEncode(request("item"))%>"><%=Request("item")%></a><small>, 
			Rev <%=itemRS("pt_rev")%> ,&nbsp;&nbsp;
			<%=itemRS("pt_desc1") & " " & itemRS("pt_desc2") & "</small>"%> 
			<%
				part = request("item")
				revision = itemRS("pt_rev")
				drawing = getDrawing(part, revision, itemRS("pt_draw"))				
				Response.Write " <small><small>[ "
				if drawing <> "" then Response.Write "<a href=""/Department/doc_con/DWG/REL/" & drawing & """>View Drawing</a> | "
				Response.Write " <a href=""parents.asp?item=" & Server.URLEncode(part) & """>Parents</a> | " & _
					"<a href=""prodstruct.asp?item=" & Server.URLEncode(part)
				if lcase(Request("c")) <> "y" then
					Response.write "&c=y"
					levelLabel = "All Levels"
				else
					levelLabel = "Single Level"
				end if
				Response.Write """>" & levelLabel & "</a> ]</small></small>" & vbCrLf
				
			%>
		</h5>
		<%	itemRS.Close
			set itemRS = Nothing
			Dim regEx, Match, Matches
			set regEx = Server.CreateObject("VBScript.RegExp")
			regEx.pattern = "^M()-(\d\d)?\d$"
			regEx.Global = true
			ecnpart = regEx.Replace(part, "")
		%>
		
		<div style="border: 2px solid rgb(0,44,122); padding: 5px;">
		<b><font size="4" color="red">Pending ECNs:</font></b>
		<%
			modecnpart = ecnpart
			Response.Write "<!--modecnpart=" & modecnpart & "-->" & vbCrLf
			if isNumeric(left(modecnpart, 1)) then
				index = Instr(modecnpart, "-")
				if index > 0 then
					if isNumeric(mid(modecnpart, index + 1, 1)) then modecnpart = left(modecnpart, index - 1)
				end if
			end if
		%>

		<div allowtransparency=true width="90%" height="75" frameborder="no" scrolling="no" style="display: block">

		  <%
		    Dim xmlDir
		    Set xmlDir = getECNXML()			
		  %>

		  <!-- parent table -->

		  <table id="parent_table" style='margin-left: 25px;'>
		    <thead>
		      <tr>
		        <!--<td><strong>Part</strong></td>-->
		        <td><strong>ECR/N</strong></td>
		        <td><strong>Status</strong></td>
		        <td><strong>Date</strong></td>
		        <td><strong>Problem</strong></td>
		      <tr>
		    </thead>
		    <tbody>
			  <%
				modpart = convertPartNum(Request("item"))
				if xmlDir.Exists(modpart) = true then
				  Response.Write Replace(xmlDir.Item(modpart), "<tr><td>", "<tr><td>" & Request("item") & "</td>") & vbCrLf
				end if 
			  %>
		    </tbody>
		  </table>
		  <div id="children_container">
		    <span style="width: 500px; background-color: rgb(175, 199, 237);">
		      <button style="width: 25px;" id="rollup_children">-</button><strong>&nbsp;&nbsp;<span id="num_children_text"></span>&nbsp;Sub Assembly ECN(s)</strong>
		    </span>
		    <div id="children_rollup_container"> <!--style="margin-left: 50px;">-->

		    <!-- children table -->
		      <table id="child_table" style="margin-left: 50px;">
		        <thead>
		          <tr>
		            <td><strong>Part</strong></td>
		            <td><strong>ECR/N</strong></td>
		            <td><strong>Status</strong></td>
		            <td><strong>Date</strong></td>
		            <td><strong>Problem</strong></td>
		          <tr>
		        </thead>
		        <tbody>
		        <%
		          getChildrenECNs Request("item"), xmlDir, false, "", ""
		        %>
		        </tbody>
		      </table>
		    </div>
		  </div>
		</div>
		</div>
		
		<div style="margin-left:40px;">
		<%
			getChildren(Request("item"))
		%>
		</div>
		<p>&nbsp; </p>
		</small>
		<!--webbot bot="HTMLMarkup" startspan -->
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
		  <input type="hidden" name="ret" value="prodstruct.asp">
		</form>

		<script type="text/javascript">
			$(function() {
			  var rollup_children = false;

			  var parent_rows = $("#parent_table > tbody > tr");
			  if (parent_rows.length <= 0) {
			    $("#parent_table").hide();
			  }

			  var child_rows = $("#child_table > tbody > tr");
			  $("#num_children_text").text(child_rows.length);
			  if (child_rows.length <= 0) {
			    $("#children_container").hide();
			  }

			  $("#rollup_children").on("click", function (e) {
			    if (!rollup_children) {
			      $("#children_rollup_container").hide();
			      $("#rollup_children").text("+");
			      rollup_children = true;
			    }
			    else {
			      $("#children_rollup_container").show();
			      $("#rollup_children").text("-");
			      rollup_children = false;
			    }
			  });

			  var linkItems = $("table > tbody > tr > td > a");
			  for (var i = 0; i < linkItems.length; i++) {
			    var linkItem = $(linkItems[i]);
			    if ($(linkItem).text().indexOf("ECN") >= 0 || $(linkItem).text().indexOf("ECR") >= 0) {
			      $(linkItem).prop("href", $(linkItem).prop("href").replace("wind", "backdraft"));
			    }
			  }

			});
		</script>
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

		function getECNXML()

    Dim sResult : sResult = GetTextFromUrl("http://nd-backdraft.entegris.com/local/ops/spgecr.nsf/Pending/ItemLookup?ReadViewEntries&Outputformat=XMl&Start=1&Count=-1")	
    Set objXML = Server.CreateObject("MSXML2.DOMDocument.3.0")
    objXML.loadXML sResult

    Dim retDir
    Set retDir = Server.CreateObject("Scripting.Dictionary")

    Dim i : i = 1
    Dim tmpKey : tmpKey = ""
    Dim tmpHtmlStr : tmlHtmlStr = ""
    Dim curPosition : curPosition = "1"
    Dim tmpPosition : tmpPosition = "1"
    For Each oNode in objXML.SelectNodes("/viewentries/viewentry")		
      tmpPosition = oNode.getAttribute("position")
      curPosition = CStr(Int(tmpPosition))

      if curPosition = tmpPosition then
        if not tmpKey = "" then
          For Each segment in Split(tmpKey, " ")
            if retDir.Exists(segment) = true then
              retDir.Item(segment) = retDir.Item(segment) & tmpHtmlStr
            else
              retDir.Add segment, tmpHtmlStr
            end if
          Next
          tmpKey = ""
          tmpHtmlStr = ""
        end if

        tmpKey = oNode.Text
      else

        tmpHtmlStr = tmpHtmlStr + oNode.Text
      end if

    Next

    Set getECNXML = retDir

  end function
  
  
  Function GetTextFromUrl(url)

    Dim oXMLHTTP
    Dim strStatusTest

    Set oXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP.3.0")

    'Response.Write "<!-- test -->" & vbCrLf

    ' This connection is dependant on the specific user: spgscanme, and this given password.
    ' If user information was changed, that could break this line.
    ' TODO: use user session to log in.
	
    oXMLHTTP.Open "GET", url, False, "ENTEGRIS\spgscanme", "F1r3F7y"
    oXMLHTTP.Send
    'Response.Write "<!-- " & oXMLHTTP.Status & " -->" & vbCrLf
    If oXMLHTTP.Status = 200 Then
      'Response.Write "<!-- GetTextFromUrl success!!! -->" & vbCrLf

      'For Each oNode In oXMLHTTP.SelectNodes("/viewentries/viewentry/entrydata/text")
      '  sValue = oNode.Text
      '  Response.Write "<!-- text tag: " & sValue & " -->" & vbCrLf
      'Next
	 	
      GetTextFromUrl = oXMLHTTP.responseText
    Else
      'Response.Write "<!-- GetTextFromUrl failure!!! -->" & vbCrLf
    End If

  End Function

  function printDir(dir)
    allKeys = dir.Keys   'Get all the keys into an array
    allItems = dir.Items 'Get all the items into an array

    For i = 0 To dir.Count - 1 'Iterate through the array
      myKey = allKeys(i)   'This is the key value
      myItem = allItems(i) 'This is the item value
      Response.Write("The " & myKey & " value in the Dictionary is " & myItem & "<br />")
    Next
  end function

  function getChildrenECNs(parent, dir, isChild, revision, draw)

    modparent = convertPartNum(parent)
    if dir.Exists(modparent) = true and isChild = true then
      htmlStr = Replace(dir.Item(modparent), "<td><a ", "<td>" & "<a href='item.asp?item=" & Server.URLEncode(parent) & "'>" & parent & "</a>" & "</td><td><a ")

      drawing = getDrawing(parent, revision, draw)

      htmlStr = Replace(htmlStr, "</tr>", "<td><small>[")
			if drawing <> "" then
        htmlStr = htmlStr & "<a href='/Department/doc_con/DWG/REL/" & drawing & "'>View Drawing</a> | "
      end if

			htmlStr = htmlStr & "<a href=""parents.asp?item=" & Server.URLEncode(parent) & """>Parents</a> | " & _
							 " <a href='prodstruct.asp?item=" & Server.URLEncode(parent) & "'>PS</a> ]</small></td></tr>"


      Response.Write htmlStr & vbCrLf

    end if

    If Response.IsClientConnected then
      set chRS = Conn.Execute("Select ps_par, ps_comp, ps_qty_per, pt_desc1, pt_desc2, ps_item_no, ps_ps_code, pt_phantom, pt_um, pt_rev, pt_draw from PUB.ps_mstr join PUB.pt_mstr on pt_domain = ps_domain and pt_part = ps_comp where ps_domain = 'SPG' and ps_par = '" & parent & "' and (ps_start <= curdate() or ps_start is null) and (ps_end >= curdate() or ps_end is null) order by ps_par, ps_item_no, ps_comp")
      if not chRS.eof then
        'Response.Write "<!-- there is something here -->" & vbCrLf
      else
        'Response.Write "<!-- there is nothing here -->" & vbCrLf
      end if
      do while not chRS.eof

        curPar = chRS("ps_comp")
        modpart = convertPartNum(curPar)

        getChildrenECNs curPar, dir, true, chRS("pt_rev"), chRS("pt_draw")

        chRS.MoveNext
      Loop

      chRS.Close

      set chRS = Nothing
    End If
  end function

  function convertPartNum(curPar)
    modpart = curPar
    if isNumeric(left(modpart, 1)) then
      index = Instr(modpart, "-")

      if index > 0 then
        ' Instr(modpart, "-EX") > 0 is a specific case check
        if isNumeric(mid(modpart, index + 1, 1)) or Instr(modpart, "-EX") > 0 then
          modpart = left(modpart, index - 1)
        end if
      end if
    end if
    convertPartNum = modpart
  end function

	function getChildren(parent)
		If not Response.IsClientConnected then exit function
		set chRS = Conn.Execute("Select ps_par, ps_comp, ps_qty_per, pt_desc1, pt_desc2, ps_item_no, ps_ps_code, pt_phantom, pt_um, pt_rev, pt_draw from PUB.ps_mstr join PUB.pt_mstr on pt_domain = ps_domain and pt_part = ps_comp where ps_domain = 'SPG' and ps_par = '" & parent & "' and (ps_start <= curdate() or ps_start is null) and (ps_end >= curdate() or ps_end is null) order by ps_par, ps_item_no, ps_comp")
		if not chRS.eof then
			Response.Write "<OL>" & vbCrLf
			haveList = true
		else
			haveList = false
		end if
		do while not chRS.eof
			itemNo = cStr(chRS("ps_item_no"))
			curPar = chRS("ps_comp")

      modpart = convertPartNum(curPar)
      Response.Write "<!-- current modpart = " & modpart & " -->" & vbCrLf
      
      Response.Write "<!-- parsed modpart = " & modpart & " -->" & vbCrLf

      if chRS("pt_phantom") or UCase(chRS("ps_ps_code")) = "X" then
				phSpan = "<span style=""background: #BAE2ED"" title=""PHANTOM"">"
				phPrint = "<span class=""phantom"">PHANTOM </span>"
			else
				phSpan = "<span>"
				phPrint = ""
			end if
			if itemNo = 0 then
				Response.Write "<LI style=""list-style-type: none"">" & phPrint & phSpan & "<a href=""item.asp?item=" & Server.URLEncode(curPar) & """>" & chRS("ps_comp") & "</a> <small>(" & chRS("ps_qty_per") & " " & chRS("pt_um") & ") " & _
					chRS("pt_desc1") & " " & chRS("pt_desc2") & vbCrLf '& "</span></small></LI>" & vbCrLf
			else
				Response.Write "<LI VALUE=""" & itemNo & """>" & phPrint & phSpan & "<a href=""item.asp?item=" & Server.URLEncode(curPar) & """>" & chRS("ps_comp") & "</a> <small>(" & chRS("ps_qty_per") & " " & chRS("pt_um") & ") " & _
					chRS("pt_desc1") & " " & chRS("pt_desc2") & vbCrLf '& "</span></small></LI>" & vbCrLf
			end if
			revision = chRS("pt_rev")
			drawing = getDrawing(curPar, revision, chRS("pt_draw"))
			Response.Write " [ "
			if drawing <> "" then Response.Write "<a href=""/Department/doc_con/DWG/REL/" & drawing & """>View Drawing</a> | "
			Response.Write " <a href=""parents.asp?item=" & Server.URLEncode(curPar) & """>Parents</a> | " & _
							 " <a href=""prodstruct.asp?item=" & Server.URLEncode(curPar) & """>PS</a> ]</small></span></LI>" & vbCrLf

			if lcase(Request("c")) = "y" then
				getChildren(curPar)
			end if
			chRS.MoveNext
		Loop
		chRS.Close
		set chRS = Nothing
		if haveList then
			Response.Write "</OL>" & vbCrLf
		end if
	end function

	function getDrawing(item, rev, stddrawing)
		Response.Write "<!--checking " & item & "," & rev & "," & stddrawing & "-->"
		set fs = Server.CreateObject("Scripting.FileSystemObject")
		drawing = mid(stddrawing,1,2) + "\" & mid(stddrawing,3,3) + "\" & mid(stddrawing,6,2) & "___" & rev & ".pdf"
		if fs.FileExists("k:\Department\doc_con\DWG\REL\" & drawing) then
			getDrawing = replace(drawing, "\", "/")
		else
			drawing = mid(item,1,2) + "\" & mid(item,3,3) + "\" & mid(item,6,2) & "___" & rev & ".pdf"
			if fs.FileExists("k:\Department\doc_con\DWG\REL\" & drawing) then
				getDrawing = replace(drawing, "\", "/")
			else
				drawing = mid(item,1,2) + "\" & mid(item,3,3) + "\" & mid(item,6,2) & "_" & rev & ".pdf"
				if fs.FileExists("k:\Department\doc_con\DWG\REL\" & drawing) then
					getDrawing = replace(drawing, "\", "/")
				elseif fs.FileExists("k:\Department\doc_con\DWG\REL\" & stddrawing & "_" & rev & ".pdf") then
					getDrawing = replace(stddrawing & "_" & rev & ".pdf", "\", "/")
				else
					getDrawing = ""
				end if
			end if
		end if
		set fs = Nothing
	end function

  

%>
