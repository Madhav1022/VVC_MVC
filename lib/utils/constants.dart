import 'package:flutter/material.dart';

abstract final class ContactProperties {
  static const String name = "Name";
  static const String mobile = "Mobile";
  static const String email = "Email";
  static const String address = "Address";
  static const String company = "Company";
  static const String designation = "Designation";
  static const String website = "Website";
}

const String emptyFieldErrMsg = 'This field must not be empty';

const String hint = "Long press and Drag each items from below list and drop in above fields";

// Database Constants
const String tableContact = 'tbl_contact';
const String tblContactColId = 'id';
const String tblContactColName = 'name';
const String tblContactColMobile = 'mobile';
const String tblContactColEmail = 'email';
const String tblContactColAddress = 'address';
const String tblContactColCompany = 'company';
const String tblContactColDesignation = 'designation';
const String tblContactColWebsite = 'website';
const String tblContactColImage = 'image';
const String tblContactColFavorite = 'favorite';
const String tblContactColUserId = 'user_id';