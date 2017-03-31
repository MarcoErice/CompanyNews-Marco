<%-- Copyright marco_erice@hotmail.com --%>

<%@ Page language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register Tagprefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>
<head>
    <title></title>

    <link href="../Content/App.css" rel="stylesheet" />
    <script src="../Scripts/bootstrap.min.js"></script>
    <script src="../Scripts/jquery-3.1.1.min.js"></script>
    <script src="../Scripts/moment.min.js"></script>
    <script type="text/javascript">

        var hostweburl;
        var appweburl;
        // Load the required SharePoint libraries
        $(document).ready(function () {
            //Get the URI decoded URLs.
            hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl"));
            appweburl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));
            // resources are in URLs in the form: web_url/_layouts/15/resource
            var scriptbase = hostweburl + "/_layouts/15/";
            // Load the js files and continue to the successHandler
            $.getScript(scriptbase + "SP.RequestExecutor.js", execCrossDomainRequest);
        });
        // Function to prepare and issue the request to get SharePoint data
        function execCrossDomainRequest() {
            // executor: The RequestExecutor object Initialize the RequestExecutor with the app web URL.
            var executor = new SP.RequestExecutor(appweburl);
            // Deals with the issue the call against the app web.
            executor.executeAsync({
                url: appweburl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('Posts')/items?@target='" + hostweburl + "/blog'&$top=5",
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: successHandler,
                error: errorHandler
            }
            );
        }
        // Function to handle the success event. Prints the data to the page.
        function successHandler(data) {
            var jsonObject = JSON.parse(data.body);
            var items = [];
            var results = jsonObject.d.results;
            items.push("<ul>");
            $(results).each(function () {
                items.push('<li>' +
                    // this.Title +
                    "<a href=\"" + hostweburl + "/blog/Lists/Posts/Post.aspx?ID=" + this.ID + "\" target=\"_blank\">" + this.Title + "</a>" +
                    '</li>');
            });
            items.push("</ul");
            $("#listResult").html(items.join(''))
        }
        // Function to handle the error event. Prints the error message to the page.
        function errorHandler(data, errorCode, errorMessage) {
            document.getElementById("internal").innerText = "Could not complete cross-domain call: " + errorMessage;
        }
        // Function to retrieve a query string value.
        function getQueryStringParameter(paramToRetrieve) {
            var params =
                document.URL.split("?")[1].split("&");
            var strParams = "";
            for (var i = 0; i < params.length; i = i + 1) {
                var singleParam = params[i].split("=");
                if (singleParam[0] == paramToRetrieve)
                    return singleParam[1];
            }
        }
    </script>


</head>
<body>
    <div id="container">
        <div><strong>Latest news</strong></div>
        <div id="listResult"></div>
    </div>

</body>
</html>
