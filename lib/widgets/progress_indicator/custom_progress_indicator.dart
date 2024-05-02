import 'package:flutter/material.dart';

class CustomProgressDialog extends StatelessWidget {
  const CustomProgressDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(14),
          ),
        ),
        shadowColor: const Color.fromRGBO(0, 0, 0, 1),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.1,
          height: MediaQuery.of(context).size.height * 0.1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: CircularProgressIndicator(
                    color: Colors.purple,
                    backgroundColor: Colors.purple.shade100),
              ),
            ],
          ),
        ),
        elevation: 0,
      ),
    );
  }
}
