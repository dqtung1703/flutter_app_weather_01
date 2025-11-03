import 'package:flutter/material.dart';

class CitySelector extends StatelessWidget {
  final List<String> cities;
  final String selectedCity;
  final ValueChanged<String> onChanged;
  final bool showLabel;

  const CitySelector({
    Key? key,
    required this.cities,
    required this.selectedCity,
    required this.onChanged,
    this.showLabel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLabel)
          const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Text('City:', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        Expanded(
          child: DropdownButton<String>(
            isExpanded: true,
            value: selectedCity,
            items: cities
                .map((city) => DropdownMenuItem<String>(
                      value: city,
                      child: Text(city, style: const TextStyle(fontSize: 16)),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
