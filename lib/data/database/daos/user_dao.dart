import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<List<UserRow>> getAllUsers() => select(users).get();

  Future<UserRow?> getUserById(int id) async {
    return (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();
  }

  Future<UserRow?> getUserByEmail(String email) async {
    return (select(users)..where((u) => u.email.equals(email)))
        .getSingleOrNull();
  }

  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  Future<bool> updateUser(UsersCompanion user) =>
      update(users).replace(user);

  Future<int> deleteUser(int id) =>
      (delete(users)..where((u) => u.id.equals(id))).go();

  Stream<UserRow?> watchUserById(int id) =>
      (select(users)..where((u) => u.id.equals(id))).watchSingleOrNull();
}
