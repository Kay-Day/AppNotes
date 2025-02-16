import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:crud/services/firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:flutter/material.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService firestoreService =
      FirestoreService(); // Đối tượng để thao tác với Firestore
  final TextEditingController textController =
      TextEditingController(); // Điều khiển nhập văn bản

  // Hàm mở hộp thoại để thêm hoặc chỉnh sửa ghi chú
  void openNoteBox({String? docID}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController, // Ô nhập văn bản
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (docID == null) {
                // Nếu không có docID, thêm ghi chú mới
                firestoreService.addNote(textController.text);
              } else {
                // Nếu có docID, cập nhật ghi chú đã có
                firestoreService.updateNote(docID, textController.text);
              }

              textController.clear(); // Xóa nội dung nhập sau khi lưu

              Navigator.pop(context); // Đóng hộp thoại
            },
            child: const Text('ADD'),
          ),
        ],
      ),
    );
  }

  // HÀM ĐĂNG XUẤT
  void logout() async {
    await FirebaseAuth.instance.signOut(); // Đăng xuất khỏi Firebase
    if (mounted) {
      Navigator.pushReplacementNamed(context, "/login"); // Chuyển về trang đăng nhập
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: "NgNghia ",
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              TextSpan(
                text: "V",
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
              TextSpan(
                text: "K",
                style: TextStyle(fontSize: 20, color: Colors.yellow),
              ),
              TextSpan(
                text: "U",
                style: TextStyle(fontSize: 20, color: Colors.blue),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 247, 168, 118),

        // THÊM NÚT LOGOUT VÀO APPBAR
        actions: [
          IconButton(
            onPressed: logout, // Khi bấm sẽ gọi hàm logout
            icon: const Icon(Icons.logout, color: Colors.white), // Icon logout
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: openNoteBox, // Mở hộp thoại nhập mới khi nhấn nút
        child: const Icon(
          Icons.add,
          color: Color.fromARGB(255, 231, 31, 31), // Màu biểu tượng "+"
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(), // Lấy dữ liệu từ Firestore theo thời gian thực
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs; // Danh sách các tài liệu Firestore

            return ListView.builder(
              itemCount: notesList.length, // Số lượng ghi chú
              itemBuilder: (context, index) {
                DocumentSnapshot document =
                    notesList[index]; // Lấy từng tài liệu Firestore
                String docID = document.id; // Lấy ID tài liệu

                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>; // Chuyển đổi dữ liệu Firestore
                String noteText = data['note']; // Lấy nội dung ghi chú

                return ListTile(
                  title: Text(noteText), // Hiển thị nội dung ghi chú
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Nút chỉnh sửa ghi chú
                      IconButton(
                        onPressed: () => openNoteBox(docID: docID),
                        icon: const Icon(Icons.settings),
                      ),
                      // Nút xóa ghi chú
                      IconButton(
                        onPressed: () => firestoreService.deleteNote(docID),
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            // Xử lý lỗi khi lấy dữ liệu Firestore
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            // Hiển thị vòng tròn tải khi chưa có dữ liệu
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
