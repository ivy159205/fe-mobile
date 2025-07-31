import 'package:google_generative_ai/google_generative_ai.dart';
import 'chatbot.dart';

class ChatbotService {
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() {
    return _instance;
  }

  // --- THAY ĐỔI 1: LƯU LẠI TIN NHẮN CHÀO BAN ĐẦU ---
  final List<ChatMessage> _initialMessages = [
    ChatMessage(text: "Xin chào! Tôi có thể giúp gì cho bạn hôm nay?", isSentByMe: false),
  ];

  // Danh sách tin nhắn sẽ được quản lý từ đây
  late List<ChatMessage> messages;

  static const String _apiKey = 'AIzaSyCkaK5Vextv_ht57Q3-13VHFMOSZo1lDMA'; // THAY API KEY CỦA BẠN
  late final GenerativeModel _model;
  late ChatSession _chat;

  ChatbotService._internal() {
    // Khởi tạo danh sách tin nhắn từ tin nhắn chào ban đầu
    messages = List<ChatMessage>.from(_initialMessages);
    _model = GenerativeModel(model: 'gemini-1.5-flash-latest', apiKey: _apiKey);
    _chat = _model.startChat();
  }

  Future<void> sendMessage(String text) async {
    try {
      final response = await _chat.sendMessage(Content.text(text));
      final botResponse = response.text;
      if (botResponse == null || botResponse.isEmpty) {
        messages.add(ChatMessage(text: 'Xin lỗi, tôi không nhận được phản hồi.', isSentByMe: false));
      } else {
        messages.add(ChatMessage(text: botResponse, isSentByMe: false));
      }
    } catch (e) {
      print('‼️ LỖI TRONG CHATBOT SERVICE: $e');
      messages.add(ChatMessage(text: 'Đã có lỗi xảy ra, vui lòng thử lại.', isSentByMe: false));
    }
  }

  // --- THAY ĐỔI 2: HÀM MỚI ĐỂ XÓA LỊCH SỬ CHAT ---
  void clearChatHistory() {
    // Xóa sạch danh sách hiện tại
    messages.clear();
    // Thêm lại tin nhắn chào ban đầu
    messages.addAll(_initialMessages);
    // Bắt đầu một phiên chat mới để AI quên đi ngữ cảnh cũ
    _chat = _model.startChat();
    print("✅ Lịch sử chat đã được xóa.");
  }
}