import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  print('🚀 Testing Figma API Connection...\n');
  
  // Read .env file
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('❌ Error: .env file not found!');
    return;
  }
  
  final envContent = await envFile.readAsString();
  final envLines = envContent.split('\n');
  
  String? token;
  String? fileId;
  
  for (final line in envLines) {
    if (line.startsWith('FIGMA_ACCESS_TOKEN=')) {
      token = line.split('=')[1].trim();
    } else if (line.startsWith('FIGMA_FILE_ID=')) {
      fileId = line.split('=')[1].trim();
    }
  }
  
  if (token == null || fileId == null) {
    print('❌ Error: FIGMA_ACCESS_TOKEN or FIGMA_FILE_ID not found in .env');
    return;
  }
  
  print('📋 Configuration:');
  print('   Token: ${token.substring(0, 10)}...');
  print('   File ID: $fileId\n');
  
  try {
    // Test 1: Get file metadata
    print('📦 Test 1: Getting file metadata...');
    
    final client = HttpClient();
    final request = await client.getUrl(
      Uri.parse('https://api.figma.com/v1/files/$fileId'),
    );
    request.headers.set('X-Figma-Token', token);
    
    final response = await request.close();
    
    if (response.statusCode == 200) {
      final responseBody = await response.transform(utf8.decoder).join();
      final data = json.decode(responseBody) as Map<String, dynamic>;
      
      print('✅ Success!');
      print('   File Name: ${data['name']}');
      print('   Last Modified: ${data['lastModified']}');
      print('   Version: ${data['version']}');
      print('   Role: ${data['role']}\n');
      
      // Test 2: Analyze document structure
      print('📊 Test 2: Analyzing document structure...');
      final document = data['document'] as Map<String, dynamic>;
      final children = document['children'] as List<dynamic>;
      print('✅ Success!');
      print('   Total pages: ${children.length}');
      for (var child in children) {
        print('   - Page: ${child['name']} (ID: ${child['id']})');
      }
      print('');
      
      print('✨ All tests passed! Figma API connection is working!');
      print('\n📝 Next steps:');
      print('   1. FigmaService class is ready at lib/core/services/figma_service.dart');
      print('   2. You can now use it in your Flutter app');
      print('   3. Run: flutter run to test in the app');
      
    } else {
      print('❌ Error: HTTP ${response.statusCode}');
      final responseBody = await response.transform(utf8.decoder).join();
      print('   Response: $responseBody');
    }
    
    client.close();
    
  } catch (e) {
    print('❌ Error: $e');
    print('\n💡 Suggestions:');
    print('   1. Check your FIGMA_ACCESS_TOKEN in .env file');
    print('   2. Check your FIGMA_FILE_ID in .env file');
    print('   3. Ensure you have access to the Figma file');
    print('   4. Verify your internet connection');
  }
}