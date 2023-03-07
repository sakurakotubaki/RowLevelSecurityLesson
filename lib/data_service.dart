import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_app/notes_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// DataServiceを使用するためのプロバイダー
final dataServiceProvider = StateProvider<DataService>((ref) => DataService(ref));

// 追加・更新・削除を行うメソッドを定義したクラス
class DataService {
  Ref ref;
  DataService(this.ref);

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> addNotes(String _body) async {
    // ローレベルセキュリティを使用するためのuserId
    String userId = supabase.auth.currentUser!.id;
    // ローレベルセキュリティを使用するためのuserIdを保存するメソッド
    await ref.read(notesProvider).from('notes').insert({'body': _body, 'user_id':userId});
  }
  // データを更新するメソッド
  Future<void> updateNotes(dynamic noteID, String _body) async {
    await ref.read(notesProvider).from('notes').update({'body': _body}).match({'id': noteID});
  }
  // データを削除するためのメソッド
  Future<void> deleteNotes(dynamic noteID) async {
    await ref.read(notesProvider).from('notes').delete().match({'id': noteID});
  }
}
