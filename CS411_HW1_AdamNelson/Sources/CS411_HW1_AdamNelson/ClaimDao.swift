import SQLite3
import Foundation

// Textbook uses JSONSerialization API (in Foundation module)
// JSONEncoder/JSONDecoder

struct Claim : Codable {
    var id : String
    var title : String
    var date : String
    var isSolved : Int
    
    init(id_: String, title_: String, date_: String, isSolved_: Int) {
        id = id_
        title = title_
        date = date_
        isSolved = isSolved_
    }
    
    init(title_: String, date_: String) {
        id = UUID().uuidString
        title = title_
        date = date_
        isSolved = 0;
    }
    
}

class ClaimDao {
    
    func addClaim(cObj : Claim) {
        let sqlStmt = String(format:"insert into claim (id, title, date, isSolved) values ('%@', '%@', '%@', '%@')", cObj.id, cObj.title, cObj.date, cObj.isSolved)
        // get database connection
        let conn = Database.getInstance().getDbConnection()
        // submit the insert sql statement
        if sqlite3_exec(conn, sqlStmt, nil, nil, nil) != SQLITE_OK {
            let errcode = sqlite3_errcode(conn)
            print("Failed to insert a Person record due to error \(errcode)")
        }
        // close the connection
        sqlite3_close(conn)
    }
    
    func getAll() -> [Claim] {
        var cList = [Claim]()
        var resultSet : OpaquePointer?
        let sqlStr = "select * from claim"
        let conn = Database.getInstance().getDbConnection()
        if sqlite3_prepare_v2(conn, sqlStr, -1, &resultSet, nil) == SQLITE_OK {
            while(sqlite3_step(resultSet) == SQLITE_ROW) {
                // Convert the record into a Person object
                // Unsafe_Pointer<CChar> Sqlite3
                let id_val = sqlite3_column_text(resultSet, 0)
                let id = String(cString: id_val!)
                let title_val = sqlite3_column_text(resultSet, 1)
                let title = String(cString: title_val!)
                let date_val = sqlite3_column_text(resultSet, 2)
                let date = String(cString: date_val!)
                let isSolved_val = sqlite3_column_int(resultSet, 3)
                let isSolved = Int(isSolved_val)
                cList.append(Claim(id_:id, title_:title, date_:date, isSolved_:isSolved))
            }
        }
        return cList
    }
}
