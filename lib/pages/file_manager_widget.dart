import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';

class FileManagerWidget extends StatefulWidget {
  const FileManagerWidget({Key? key}) : super(key: key);

  @override
  _FileManagerWidgetState createState() => _FileManagerWidgetState();
}

class _FileManagerWidgetState extends State<FileManagerWidget> {
  final FileManagerController controller = FileManagerController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await controller.isRootDirectory()) {
          Navigator.of(context).pop();
        } else {
          controller.goToParentDirectory();
        }
      },
      child: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                onPressed: () => createFolder(context),
                icon: Icon(Icons.create_new_folder_outlined),
              ),
              IconButton(
                onPressed: () => sort(context),
                icon: Icon(Icons.sort_rounded),
              ),
              IconButton(
                onPressed: () => selectStorage(context),
                icon: Icon(Icons.sd_storage_rounded),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.home),
              )
            ],
            title: ValueListenableBuilder<String>(
              valueListenable: controller.titleNotifier,
              builder: (context, title, _) => Text(title),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () async {
                await controller.goToParentDirectory();
              },
            ),
            backgroundColor: Colors.deepOrange,
          ),
          body: Container(
            margin: EdgeInsets.all(10),
            child: FileManager(
              controller: controller,
              builder: (context, snapshot) {
                final List<FileSystemEntity> entities = snapshot;
                return ListView.builder(
                  itemCount: entities.length,
                  itemBuilder: (context, index) {
                    FileSystemEntity entity = entities[index];
                    return Card(
                      child: ListTile(
                        leading: FileManager.isFile(entity)
                            ? Icon(Icons.feed_outlined)
                            : Icon(Icons.folder),
                        title: Text(FileManager.basename(entity)),
                        subtitle: subtitle(entity),
                        onTap: () async {
                          if (FileManager.isDirectory(entity)) {
                            controller.openDirectory(entity);
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
          )),
    );
  }

  Widget subtitle(FileSystemEntity entity) {
    return FutureBuilder<FileStat>(
      future: entity.stat(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (entity is File) {
            int size = snapshot.data!.size;
            return Text(
              "${FileManager.formatBytes(size)}",
            );
          }
          return Text(
            "${snapshot.data!.modified}",
          );
        } else {
          return Text("");
        }
      },
    );
  }

  selectStorage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: FutureBuilder<List<Directory>>(
          future: FileManager.getStorageList(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final List<FileSystemEntity> storageList = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: storageList
                        .map((e) => ListTile(
                              title: Text(
                                "${FileManager.basename(e)}",
                              ),
                              onTap: () {
                                controller.openDirectory(e);
                                Navigator.pop(context);
                              },
                            ))
                        .toList()),
              );
            }
            return Dialog(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }

  sort(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                  title: Text("Name"),
                  onTap: () {
                    controller.sortBy(SortBy.name);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("Size"),
                  onTap: () {
                    controller.sortBy(SortBy.size);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("Date"),
                  onTap: () {
                    controller.sortBy(SortBy.date);
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: Text("type"),
                  onTap: () {
                    controller.sortBy(SortBy.type);
                    Navigator.pop(context);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  createFolder(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController folderName = TextEditingController();
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: TextField(
                    controller: folderName,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FileManager.createFolder(
                          controller.getCurrentPath, folderName.text);
                      controller.setCurrentPath =
                          controller.getCurrentPath + "/" + folderName.text;
                    } catch (e) {}

                    Navigator.pop(context);
                  },
                  child: Text('Create Folder'),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
