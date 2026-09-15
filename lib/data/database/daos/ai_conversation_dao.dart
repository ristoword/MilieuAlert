import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'ai_conversation_dao.g.dart';

@DriftAccessor(tables: [AiConversations])
class AiConversationDao extends DatabaseAccessor<AppDatabase>
    with _$AiConversationDaoMixin {
  AiConversationDao(super.db);

  Future<List<AiConversationRow>> getAllConversations() =>
      select(aiConversations).get();

  Future<List<AiConversationRow>> getConversationsBySession(
          String sessionId) =>
      (select(aiConversations)
            ..where((c) => c.sessionId.equals(sessionId))
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .get();

  Future<List<AiConversationRow>> getConversationsForUser(int userId) =>
      (select(aiConversations)..where((c) => c.userId.equals(userId))).get();

  Future<int> insertConversation(AiConversationsCompanion conversation) =>
      into(aiConversations).insert(conversation);

  Future<void> deleteConversation(int id) =>
      (delete(aiConversations)..where((c) => c.id.equals(id))).go();

  Stream<List<AiConversationRow>> watchConversationsBySession(
          String sessionId) =>
      (select(aiConversations)
            ..where((c) => c.sessionId.equals(sessionId))
            ..orderBy([(c) => OrderingTerm.asc(c.createdAt)]))
          .watch();
}
