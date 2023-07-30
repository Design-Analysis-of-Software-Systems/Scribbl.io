import 'package:flutter/material.dart';
class CustomTextField extends StatelessWidget {
  //we created this widget to reduce redundancy of input things
  final TextEditingController nameController;
  //nameController is just not only name controller but also hintText Controller
  //that's why the youtuber changed the name Controller to controller but we will keep it the same!
  final String hintText;
  //removed const below since name controller will keep changing
  //added required modifier since we will always need it
  CustomTextField({Key? key,required this.nameController,required this.hintText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: nameController,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      //  whenever the user clicks,we want the text enabled and want to give the same border
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 14),
        filled: true,
        fillColor: const Color(0xffF5F5FA),
        // hintText: "Enter Your Name",
        //  creating a template instead of directly writing enter your name since you will need to keep on changing that
          hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        )
      ),
    );
  }
}
