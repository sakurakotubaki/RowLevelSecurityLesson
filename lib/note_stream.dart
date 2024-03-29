import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_app/data_service.dart';
import 'package:supabase_app/notes_provider.dart';
import 'package:supabase_app/start_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesStream extends ConsumerWidget {
  const NotesStream({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesStream = ref.watch(notesStreamProvider);
    final _body = ref.watch(bodyProvider);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                // ログアウトするボタン.
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const StartPage()));
                }
              },
              icon: const Icon(Icons.logout)),
        ],
        title: const Text('Notes App'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // showDialogのFormからデータをPostする.
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  title: const Text('ノートを作成'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                  children: [
                    TextFormField(
                      controller: _body,
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          // Formから取得したデータを保存する.
                          await ref
                              .read(dataServiceProvider.notifier)
                              .state
                              .addNotes(_body.text);
                          Navigator.of(context).pop();
                        },
                        child: const Text('追加'))
                  ],
                );
              });
        },
        child: const Icon(Icons.pending_actions),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: 400,
          height: 600,
          child: notesStream.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Text(error.toString()),
            data: (notes) {
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SimpleDialog(
                                        title: const Text('ノートを更新'),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 1.0),
                                        children: [
                                          TextFormField(
                                            controller: _body,
                                          ),
                                          ElevatedButton(
                                              onPressed: () async {
                                                // Listのデータを受け取りMapでindexから、選択したリストのidを取得する.
                                                final noteID =
                                                    notes[index]['id'];
                                                // Formから取得したデータを更新する.
                                                ref
                                                    .read(dataServiceProvider
                                                        .notifier)
                                                    .state
                                                    .updateNotes(
                                                        noteID, _body.text);
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text('更新'))
                                        ],
                                      );
                                    });
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              )),
                          IconButton(
                            onPressed: () async {
                              // Listのデータを受け取りMapでindexから、選択したリストのidを取得する.
                              final noteID = notes[index]['id'];
                              // ボタンを押すとクエリが実行されて、データが削除される!
                              ref
                                  .read(dataServiceProvider.notifier)
                                  .state
                                  .deleteNotes(noteID);
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(note['body']),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
