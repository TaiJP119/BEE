import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:image_picker/image_picker.dart';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  State<AIPage> createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  int maxStandard = 1; // standard 1
  String maxSubject = "english";
  final textController = TextEditingController();
  XFile? image;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe by AI',
            style: GoogleFonts.notoSans(color: Colors.white, fontSize: 18.0)),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(255, 238, 47, 1),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                // "How many standard are you cooking for?",
                "Standard?",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Slider(
                divisions: 12,
                label: "$maxStandard standard",
                value: maxStandard.toDouble(),
                min: 1,
                max: 12,
                activeColor: const Color.fromRGBO(255, 238, 47, 1),
                onChanged: (double value) {
                  setState(() {
                    maxStandard = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 30),
              SegmentedButton(
                  multiSelectionEnabled: false,
                  segments: const [
                    ButtonSegment(label: Text("BI"), value: "english"),
                    ButtonSegment(label: Text("BM"), value: "bm"),
                    ButtonSegment(label: Text("BC"), value: "bc"),
                    ButtonSegment(label: Text("MATH"), value: "math"),
                  ],
                  selected: {maxSubject},
                  onSelectionChanged: (selections) {
                    setState(() {
                      maxSubject = selections.first;
                    });
                  }),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: TextFormField(
                  controller: textController,
                  decoration: const InputDecoration(hintText: 'Describe'),
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  imagePickerMethod();
                },
                child: SizedBox(
                  height: 300,
                  width: 300,
                  child: image != null
                      ? Image.file(File(image!.path))
                      : Image.asset('assets/images/pick_image.png'),
                ),
              ),
              const SizedBox(height: 100),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    var recipe = await generationRecipeByGeminiMethod(
                        maxStandard, maxSubject, textController.text, image);
                    openButtomBar(recipe);
                  } catch (e) {
                    log(e.toString());

                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Something went wrong')));
                  }

                  setState(() {
                    isLoading = false;
                  });
                },
                style: ElevatedButton.styleFrom(fixedSize: const Size(400, 40)),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('AI assist'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Show loading
  void showLoading() {
    setState(() {
      isLoading = true;
    });
  }

  // Hide loading
  void hideLoading() {
    setState(() {
      isLoading = false;
    });
  }

  // Method to pick image from gallery
  Future<void> imagePickerMethod() async {
    final picker = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picker != null) {
      setState(() {
        image = picker;
      });
    }
  }

  // Method to open bottom bar
  void openButtomBar(var recipe) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(recipe.toString()),
            ),
          );
        });
  }

  // Method to generate recipe by Gemini
  Future<List<String>> generationRecipeByGeminiMethod(int standard,
      String maxSubject, String? intoleranceOrLimits, XFile? picture) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: 'AIzaSyDbYz3Wb6hOxA3Z0XtjiG0XVJ6PTPU-v98',
    );

    final prompt = _generatePrompt(standard, maxSubject, intoleranceOrLimits);
    final image = await picture!.readAsBytes();
    final mimetype = picture.mimeType ?? 'image/jpeg';

    final response = await model.generateContent([
      Content.multi([TextPart(prompt), DataPart(mimetype, image)])
    ]);

    // return response.skipWhile((response) => response.text != null).map((event) => event.text!);
    log(response.text!);
    return [response.text!];
  }

  // Method to generate prompt
  String _generatePrompt(
      // int standard, int maxSubject, String? intoleranceOrLimits) {
      int standard,
      String maxSubject,
      String? intoleranceOrLimits) {
    String prompt =
        '''Based on the image given, I want the answer for standard ${standard.toString()}  and the subject is ${maxSubject.toString()} ''';

    if (intoleranceOrLimits != null) {
      prompt += 'Additional description of the questions: $intoleranceOrLimits';
    }

    return prompt;
  }
}
