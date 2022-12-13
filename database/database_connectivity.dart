import 'package:mongo_dart/mongo_dart.dart';

class DatabaseConnectivity {
  Future<Db> connectToDatabase() async {
   //localhost 
  // final db = Db('mongodb://localhost:27017/TodoDatabase');

  //production database
  final db = await Db.create('mongodb+srv://user:user@cluster0.sq62igg.mongodb.net:27017/TodoDB?retryWrites=true&w=majority');
  await db.open();
  return db;
}

void closeDatabaseConnection(Db db) {
  db.close();
}
}
