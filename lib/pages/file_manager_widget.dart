import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';

class FileManagerWidget extends StatelessWidget {
  // final FileManagerWidget({Key? key}) : super(key: key);

  final FileManagerController controller = FileManagerController();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(10),
        child: FileManager(
          controller: controller,
          builder: (context, snapshot) {
            final List<FileSystemEntity> entities = snapshot;
            return ListView.builder(
              itemCount: entities.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: FileManager.isFile(entities[index])
                        ? Icon(Icons.feed_outlined)
                        : Icon(Icons.folder),
                    title: Text(FileManager.basename(entities[index])),
                    onTap: () {
                      if (FileManager.isDirectory(entities[index])) {
                        controller
                            .openDirectory(entities[index]); // open directory
                      } else {
                        // Perform file-related tasks.
                      }
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}
