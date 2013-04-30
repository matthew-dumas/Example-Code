Imports MySql.Data.MySqlClient

Public Class MySQL
    Implements MySQLConnect

    Public Sub New()
    End Sub

    Function runQuery(ByVal server As String, ByVal user As String, ByVal password As String, ByVal query As String) As String Implements MySQLConnect.runQuery
        Dim conn As MySqlConnection
        Dim connStr As String = String.Format("server={0};user id={1}; password={2}; database=mysql; pooling=false", server, user, password)
        Try
            conn = New MySqlConnection(connStr)
            conn.Open()
        Catch ex As Exception
            logError("Error opening connection: " & connStr, ex.Message.ToString())
            Return "-99"
        End Try

        Dim cmd As New MySqlCommand(query, conn)
        Dim reader As MySqlDataReader
        Dim out As String = "| "
        Try
            reader = cmd.ExecuteReader()
            Dim i As Integer = 0
            While (reader.Read())
                While i < reader.FieldCount
                    out = out & reader.GetString(i) & " | "
                    i = i + 1
                End While
                i = 0
                out = out & vbNewLine
            End While
        Catch ex As Exception
            logError("Error reading data: " & query, ex.Message.ToString())
            Return "-98"
        End Try

        Try
            conn.Close()
        Catch ex As Exception
            logError("Error reading data: " & query, ex.Message.ToString())
            Return "-97"
        End Try


        Return out
    End Function

    Private Function logError(ByVal MeaningfulError As String, ByVal exception As String) As Integer
        Dim timeString As String = "dd MMM yyyy, hh:mm:ss.fff"
        Dim now As Date = Date.Now
        Dim fileName As String = "C:\\Users\\matt.dumas\\Documents\\sql_error_log.csv"

        Dim errorString As String = now.ToString(timeString)

        errorString = errorString & "," & """" & MeaningfulError & """" & "," & """" & exception & """"
        errorString = Replace(errorString, vbNewLine, "")

        Try
            Dim FH As New System.IO.StreamWriter(fileName, True)
            FH.WriteLine(errorString)
            FH.Close()
        Catch ex As Exception
            ' This is where we threaten the computer with a visit from Chuck Norris.
            Return 0
        End Try

        Return 1
    End Function

End Class
