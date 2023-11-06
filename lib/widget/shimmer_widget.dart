import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Shimmer getShimmerLoading() {
  return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 20,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return ListTile(
              leading: Container(
                width: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.white,
                ),
              ),
              title: Container(
                height: 10,
                color: Colors.white,
              ),
              subtitle: Container(
                height: 7,
                color: Colors.white,
              ));
        },
      ));
}
