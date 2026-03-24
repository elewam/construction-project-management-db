using System;
using System.Data.SqlClient;
using System.IO;
using System.Data.OleDb;

class Program
{
    static void Main(string[] args)
    {
        string sqlConnectionString = "Data Source=your_sql_server;Initial Catalog=your_database;Integrated Security=True;";
        string accessConnectionString = "Provider=Microsoft.ACE.OLEDB.12.0;Data Source=your_access_database.accdb;"

        // Create SQL Server database
        using (SqlConnection sqlConnection = new SqlConnection(sqlConnectionString))
        {
            sqlConnection.Open();
            SqlCommand command = new SqlCommand("CREATE DATABASE your_database", sqlConnection);
            command.ExecuteNonQuery();
        }

        // Export SQL Server database to Access format
        ExportToAccess(sqlConnectionString, accessConnectionString);
    }

    static void ExportToAccess(string sqlConnectionString, string accessConnectionString)
    {
        using (SqlConnection sqlConnection = new SqlConnection(sqlConnectionString))
        {
            sqlConnection.Open();

            string query = "SELECT * FROM your_table"; // Adjust the query according to your needs
            SqlCommand command = new SqlCommand(query, sqlConnection);

            OleDbConnection accessConnection = new OleDbConnection(accessConnectionString);
            accessConnection.Open();

            // Create table in Access
            OleDbCommand createTableCommand = new OleDbCommand("CREATE TABLE your_table (Column1 INT, Column2 TEXT)", accessConnection);
            createTableCommand.ExecuteNonQuery();

            using (OleDbTransaction transaction = accessConnection.BeginTransaction())
            {
                OleDbCommand insertCommand = new OleDbCommand();
                insertCommand.Connection = accessConnection;
                insertCommand.Transaction = transaction;

                using (SqlDataReader reader = command.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        insertCommand.CommandText = "INSERT INTO your_table (Column1, Column2) VALUES (@value1, @value2)";
                        insertCommand.Parameters.Clear();
                        insertCommand.Parameters.AddWithValue("@value1", reader["Column1"]);
                        insertCommand.Parameters.AddWithValue("@value2", reader["Column2"]);
                        insertCommand.ExecuteNonQuery();
                    }
                }
                transaction.Commit();
            }
            accessConnection.Close();
        }
    }
}