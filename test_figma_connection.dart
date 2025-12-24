import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'lib/core/services/figma_service.dart';

Future<void> main() async {
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  print('🚀 Testing Figma API Connection...\n');
  
  final figmaService = FigmaService();
  
  try {
    // Test 1: Get file metadata
    print('📋 Test 1: Getting file metadata...');
    final metadata = await figmaService.getFileMetadata();
    print('✅ Success!');
    print('   File Name: ${metadata['name']}');
    print('   Last Modified: ${metadata['lastModified']}');
    print('   Version: ${metadata['version']}');
    print('   Role: ${metadata['role']}\n');
    
    // Test 2: Get full file data
    print('📦 Test 2: Getting full file data...');
    final fileData = await figmaService.getFile();
    final document = fileData['document'] as Map<String, dynamic>;
    final children = document['children'] as List<dynamic>;
    print('✅ Success!');
    print('   Total pages: ${children.length}');
    for (var child in children) {
      print('   - Page: ${child['name']} (ID: ${child['id']})');
    }
    print('');
    
    // Test 3: Get styles
    print('🎨 Test 3: Getting styles...');
    final styles = await figmaService.getStyles();
    print('✅ Success!');
    print('   Styles data retrieved\n');
    
    // Test 4: Get components
    print('🧩 Test 4: Getting components...');
    final components = await figmaService.getComponents();
    print('✅ Success!');
    print('   Components data retrieved\n');
    
    // Test 5: Connection test
    print('🔌 Test 5: Connection test...');
    final isConnected = await figmaService.testConnection();
    if (isConnected) {
      print('✅ Connection successful!\n');
    } else {
      print('❌ Connection failed!\n');
    }
    
    print('✨ All tests passed! Figma API is ready to use.');
    
  } catch (e) {
    print('❌ Error: $e');
    print('\n💡 Suggestions:');
    print('   1. Check your FIGMA_ACCESS_TOKEN in .env file');
    print('   2. Check your FIGMA_FILE_ID in .env file');
    print('   3. Ensure you have access to the Figma file');
    print('   4. Verify your internet connection');
  }
}