import UIKit

var str = """

[{"icon":"clock","regDate":"2020-02-24 19:35:16.0","id":1,"title":"ㄴㄴ"},{"icon":"clock","regDate":"2020-02-24 20:28:42.0","id":3,"title":"test_1582543722.22029"},{"icon":"clock","regDate":"2020-02-24 20:31:38.0","id":4,"title":"test_1582543897.935044"},{"icon":"clock","regDate":"2020-02-24 20:33:07.0","id":5,"title":"test_1582543987.263264"},{"icon":"clock","regDate":"2020-02-24 20:34:27.0","id":6,"title":"test_1582544067.157992"},{"icon":"clock","regDate":"2020-02-24 20:36:49.0","id":7,"title":"test_1582544209.355167"},{"icon":"clock","regDate":"2020-02-24 20:38:30.0","id":9,"title":"test_1582544310.707113"},{"icon":"pencil","regDate":"2020-02-24 20:42:01.0","id":10,"title":"update_1582545483.74549"},{"icon":"clock","regDate":"2020-02-24 20:53:35.0","id":11,"title":"test_1582545215.556925"}]


"""

let json = str.data(using: .utf8)

struct Todo: Codable {
    let id: Int?
    let icon: String?
    let title: String?
    let regDate: String?
}

let decoded = try! JSONDecoder().decode([Todo].self, from: json!)

for item in decoded {
    print("\(item.id ?? 0)\t\(item.icon ?? "")\t\(item.title ?? "")\t\(item.regDate ?? "")")
}
