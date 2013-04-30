' NOTE: You can use the "Rename" command on the context menu to change the interface name "IService1" in both code and config file together.
<ServiceContract()>
Public Interface MySQLConnect

    <OperationContract()>
    Function runQuery(ByVal server As String, ByVal user As String, ByVal password As String, ByVal query As String) As String

End Interface

