using Microsoft.Data.SqlClient;

namespace LibraryMangementDAL
{
    /// <summary>
    /// Provides data access methods for managing books in the database, including retrieving all books, retrieving
    /// available books, adding new books, and deleting existing books.
    /// </summary>
    /// <remarks>This class interacts with the database to perform CRUD operations on the Books table. It
    /// requires a valid database connection to function correctly. Ensure that the database schema matches the expected
    /// structure for the methods to work as intended.</remarks>
    public class BookDAL
    {
        
        // Get All Books      
        public List<(int Id, string Title, string Author, bool IsAvailable)> GetAllBooks()
        {
            var list = new List<(int, string, string, bool)>();

            using SqlConnection conn = DBHelper.GetConnection();
            conn.Open();

            using SqlCommand cmd = new SqlCommand(
                "SELECT BookID, Title, Author, IsAvailable FROM Books", conn);
            using SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
                list.Add((reader.GetInt32(0), reader.GetString(1),
                          reader.GetString(2), reader.GetBoolean(3)));

            return list;
        }

        // ================================================
        // Get Available Books using VIEW
        // ================================================
        public List<(int Id, string Title, string Author)> GetAvailableBooks()
        {
            var list = new List<(int, string, string)>();

            using SqlConnection conn = DBHelper.GetConnection();
            conn.Open();

            using SqlCommand cmd = new SqlCommand(
                "SELECT BookID, Title, Author FROM AvailableBooks", conn);
            using SqlDataReader reader = cmd.ExecuteReader();

            while (reader.Read())
                list.Add((reader.GetInt32(0), reader.GetString(1), reader.GetString(2)));

            return list;
        }

        // ================================================
        // Add Book
        // ================================================
        public bool AddBook(string title, string author)
        {
            using SqlConnection conn = DBHelper.GetConnection();
            conn.Open();

            using SqlCommand cmd = new SqlCommand(
                "INSERT INTO Books (Title, Author) VALUES (@Title, @Author)", conn);
            cmd.Parameters.AddWithValue("@Title",  title);
            cmd.Parameters.AddWithValue("@Author", author);

            return cmd.ExecuteNonQuery() > 0;
        }

        // ================================================
        // Delete Book
        // ================================================
        public bool DeleteBook(int bookId)
        {
            using SqlConnection conn = DBHelper.GetConnection();
            conn.Open();

            using SqlCommand cmd = new SqlCommand(
                "DELETE FROM Books WHERE BookID = @BookID", conn);
            cmd.Parameters.AddWithValue("@BookID", bookId);

            return cmd.ExecuteNonQuery() > 0;
        }
    }
}
