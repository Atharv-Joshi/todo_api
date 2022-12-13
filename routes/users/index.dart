import 'package:dart_frog/dart_frog.dart';
import '../../database/database_connectivity.dart';

Future<Response> onRequest(RequestContext context) async {
  final requestType = context.request.method.value;

  final dbConnectivity = DatabaseConnectivity();
  final db = await dbConnectivity.connectToDatabase();
  final collection = db.collection('users');

  switch (requestType) {
    case 'POST':
      {
        final data = await context.request.json() as Map<String, dynamic>;
        await collection.insertOne(data);
        dbConnectivity.closeDatabaseConnection(db);
        return Response.json(body: data, statusCode: 201);
      }
    default:
      {
        return Response(body: 'Invalid Http Method', statusCode: 403);
      }
  }
}
