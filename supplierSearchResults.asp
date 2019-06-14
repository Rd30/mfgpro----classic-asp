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

    <div align="center">
      <table border="2">
        <tr>
          <td>
            <table border="0" cellspacing="3" cellpadding="3">
              <tr>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>Part</strong></font></td>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>Description</strong></font></td>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>Status</strong></font></td>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>Supplier</strong></font></td>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>Supplier Item</strong></font></td>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>MFG</strong></font></td>
                <td bgcolor="#000000"><font color="#FFFFFF"><strong>MFG Item</strong></font></td>
              </tr>
                <%
                	Set Conn = Server.CreateObject("ADODB.Connection")
					SPG = "DSN=SPG;UID=mfg;PWD="
                	Conn.Open SPG

                	if isNull(Request("exact")) or Request("Exact") = "" then
                		SQL = "select vp_part, vp_vend, vp_vend_part, vp_mfgr, vp_mfgr_part, pt_desc1, pt_desc2, pt_status " & _
                				" from PUB.vp_mstr, PUB.pt_mstr where pt_domain = 'SPG' and vp_part = pt_part and " & _
                				" (vp_vend like '%" & Request("search") & "%' or vp_vend_part like '%" & Request("search") & "%' or " & _
                				" vp_mfgr like '%" & Request("search") & "%' or vp_mfgr_part like '%" & Request("search") & "%') order by vp_part"
                	else
                		SQL = 	"select vp_part, vp_vend, vp_vend_part, vp_mfgr, vp_mfgr_part, pt_desc1, pt_desc2, pt_status " & _
                				" from PUB.vp_mstr, PUB.pt_mstr where pt_domain = 'SPG' and vp_part = pt_part and " & _
                				" (vp_vend = '" & Request("search") & "' or vp_vend_part = '" & Request("search") & "' or " & _
                				" vp_mfgr = '" & Request("search") & "' or vp_mfgr_part = '" & Request("search") & "') order by vp_part"
                	end if
                	Response.Write "<" & "!--" & SQL & "--" & ">" & vbCrLf
                	set RS = Conn.Execute(SQL)

                	do while not RS.eof
                %>
              <tr>
                <td><small><%=RS("vp_part")%></small></td>
                <td><small><%=RS("pt_desc1") & " " & RS("pt_desc2")%></small></td>
                <td><small><%=RS("pt_status")%></small></td>
                <td><small><%=RS("vp_vend")%></small></td>
                <td><small><%=RS("vp_vend_part")%></small></td>
                <td><small><%=RS("vp_mfgr")%></small></td>
                <td><small><%=RS("vp_mfgr_part")%></small></td>
              </tr>
                <%
                	RS.MoveNext
                	Loop

                	RS.Close
                	Set RS = Nothing
                	Conn.Close
                	Set Conn = Nothing
                %>
            </table>
          </td>
        </tr>
      </table>
   </div>
   <script type="text/javascript" src="http://nd-wind.entegris.com/gp-slo/gp-slo.js"></script>
		<script type="text/javascript">
	      $(document).ready(function () {
	        $('#pageTitleDiv').html("");
	        $('#pageTitleDiv').html("<h5>Supplier Search</h5>");
			$('#shortPageTitleDiv').html("");
			$('#shortPageTitleDiv').html("<h5>Sup Srch.</h5>");
	      })
	  </script>
  </body>
</html>
