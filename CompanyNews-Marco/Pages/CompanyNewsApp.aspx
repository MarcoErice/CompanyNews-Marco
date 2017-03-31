<%-- Copyright marco_erice@hotmail.com --%>

<%@ Page Language="C#" Inherits="Microsoft.SharePoint.WebPartPages.WebPartPage, Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<%@ Register TagPrefix="SharePoint" Namespace="Microsoft.SharePoint.WebControls" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="Utilities" Namespace="Microsoft.SharePoint.Utilities" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>
<%@ Register TagPrefix="WebPartPages" Namespace="Microsoft.SharePoint.WebPartPages" Assembly="Microsoft.SharePoint, Version=15.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c" %>

<WebPartPages:AllowFraming ID="AllowFraming" runat="server" />

<html>
<head>
    <title></title>

    <link href="../Content/App.css" rel="stylesheet" />
    <script src="../Scripts/jquery-3.1.1.min.js"></script>
    <script src="../Scripts/bootstrap.min.js"></script>
    <script src="../Scripts/moment.min.js"></script>
    <%--<script src="../Scripts/App.js"></script>--%>
    <script type="text/javascript">

        var hostweburl;
        var appweburl;

        $(document).ready(function () {

            hostweburl = decodeURIComponent(getQueryStringParameter("SPHostUrl")) + "/CompanyNewsSite";  // + "/subsite"
            appweburl = decodeURIComponent(getQueryStringParameter("SPAppWebUrl"));

            var scriptbase = hostweburl + "/_layouts/15/";

            $.getScript(scriptbase + "SP.RequestExecutor.js", execCrossDomainRequest);
        });

        function execCrossDomainRequest() {

            var executor = new SP.RequestExecutor(appweburl);

            executor.executeAsync({
                url: appweburl + "/_api/SP.AppContextSite(@target)/web/lists/getbytitle('CompanyNewsList')/items?@target='" + hostweburl + "'&$top=5",
                method: "GET",
                headers: { "Accept": "application/json; odata=verbose" },
                success: successHandler,
                error: errorHandler
            }
            );
        }

        function successHandler(data) {
            var jsonObject = JSON.parse(data.body);
            var items = [];
            var results = jsonObject.d.results;
            items.push("<ul>");
            $(results).each(function () {

                var createdDay = moment(this.Created).format("YYYY-MM-DD"); // so that the date appears in correct format

                items.push('<li>' +
                    "<a href=\"" + hostweburl + "/Lists/CompanyNewsList/DispForm.aspx?ID=" + this.ID + "\" target=\"_blank\">" + this.Title + "</a>" +
                    "<div>" +
                    createdDay +
                    "</div>" +
                    "<div>" +
                    this.Category +
                    "</div>" +
                    "</br>" +
                    '</li>');
            });
            items.push("</ul");
            $("#listResult").html(items.join(''))
        }

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
