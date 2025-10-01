

/// LCM-to-Dart code generator that correctly handles LCM protocol structure
class LcmDartGenerator {
  /// Generate Dart class from LCM struct definition
  static String generateClass(String lcmContent) {
    final lines = lcmContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    String? packageName;
    String? structName;
    final List<String> fields = [];

    for (final line in lines) {
      if (line.startsWith('package ')) {
        packageName = line.substring(8).replaceAll(';', '').trim();
      } else if (line.startsWith('struct ')) {
        structName = line.substring(7).replaceAll('{', '').trim();
      } else if (line.contains(' ') &&
          !line.startsWith('//') &&
          !line.startsWith('}')) {
        fields.add(line.replaceAll(';', '').trim());
      }
    }

    if (structName == null) throw Exception('No struct found');

    return _generateDartClass(packageName ?? 'lcm', structName, fields);
  }

  static String _generateDartClass(
      String package, String structName, List<String> fields) {
    final className = _toPascalCase(structName);
    final buffer = StringBuffer();

    // Class header
    buffer.writeln('import \'dart:typed_data\';');
    buffer.writeln('');
    buffer.writeln('/// Generated LCM type: $package.$structName');
    buffer.writeln('class $className {');

    // Fields
    final List<LcmField> parsedFields = [];

    for (final field in fields) {
      final parts = field.split(' ').where((s) => s.isNotEmpty).toList();
      if (parts.length >= 2) {
        final type = parts[0];
        final nameWithArray = parts[1];

        // Handle arrays like "data[256]"
        String name = nameWithArray;
        bool isArray = false;
        int arraySize = 0;

        if (nameWithArray.contains('[') && nameWithArray.contains(']')) {
          isArray = true;
          final arrayMatch =
              RegExp(r'(\w+)\[(\d+)\]').firstMatch(nameWithArray);
          if (arrayMatch != null) {
            name = arrayMatch.group(1)!;
            arraySize = int.parse(arrayMatch.group(2)!);
          }
        }

        final dartType = _lcmTypeToDartType(type, isArray);
        parsedFields.add(LcmField(name, type, dartType, isArray, arraySize));

        buffer.writeln('  final $dartType $name;');
      }
    }

    buffer.writeln('');

    // Constructor
    buffer.writeln('  $className({');
    for (final field in parsedFields) {
      final required = field.dartType.endsWith('?') ? '' : 'required ';
      buffer.writeln('    ${required}this.${field.name},');
    }
    buffer.writeln('  });');
    buffer.writeln('');

    // Encode method (NOTE: This doesn't include the LCM hash - you'd need to compute that)
    buffer.writeln('  Uint8List encode() {');
    buffer.writeln('    final dataSize = _getDataSize();');
    buffer.writeln(
        '    final buffer = ByteData(8 + dataSize); // 8 bytes for LCM hash + data');
    buffer.writeln('    int offset = 0;');
    buffer.writeln('');
    buffer.writeln('    // TODO: Write LCM type hash (8 bytes)');
    buffer.writeln(
        '    // For now, writing zeros - you need to compute the actual hash');
    buffer.writeln('    buffer.setInt64(offset, 0, Endian.big); offset += 8;');
    buffer.writeln('');

    for (final field in parsedFields) {
      buffer.writeln('    ${_generateEncodeField(field)}');
    }

    buffer.writeln('');
    buffer.writeln('    return buffer.buffer.asUint8List();');
    buffer.writeln('  }');
    buffer.writeln('');

    // Decode method - correctly skips LCM hash
    buffer.writeln('  static $className decode(Uint8List bytes) {');
    buffer.writeln('    final data = ByteData.sublistView(bytes);');
    buffer.writeln('    int offset = 8; // Skip 8-byte LCM type hash');
    buffer.writeln('');

    for (final field in parsedFields) {
      buffer.writeln('    ${_generateDecodeField(field)}');
    }

    buffer.writeln('');
    buffer.writeln('    return $className(');
    for (final field in parsedFields) {
      buffer.writeln('      ${field.name}: ${field.name},');
    }
    buffer.writeln('    );');
    buffer.writeln('  }');
    buffer.writeln('');

    // Data size calculation (without hash)
    buffer.writeln('  int _getDataSize() {');
    buffer.writeln('    int size = 0;');
    for (final field in parsedFields) {
      buffer.writeln('    ${_generateSizeCalculation(field)}');
    }
    buffer.writeln('    return size;');
    buffer.writeln('  }');
    buffer.writeln('');

    // Total encoded size (with hash)
    buffer.writeln(
        '  static int get encodedSize => 8 + ${_calculateDataSize(parsedFields)}; // 8-byte hash + data');
    buffer.writeln('');

    // toString
    buffer.writeln('  @override');
    buffer.writeln(
        '  String toString() => \'$className(${parsedFields.map((f) => '${f.name}: \$${f.name}').join(', ')})\';');

    buffer.writeln('}');

    return buffer.toString();
  }

  static String _lcmTypeToDartType(String lcmType, bool isArray) {
    final baseType = switch (lcmType) {
      'int8_t' || 'int16_t' || 'int32_t' || 'int64_t' => 'int',
      'uint8_t' || 'uint16_t' || 'uint32_t' || 'uint64_t' => 'int',
      'float' || 'double' => 'double',
      'string' => 'String',
      'boolean' => 'bool',
      _ => 'dynamic', // For custom types
    };

    return isArray ? 'List<$baseType>' : baseType;
  }

  static String _generateEncodeField(LcmField field) {
    if (field.isArray) {
      return switch (field.lcmType) {
        'int8_t' => '''
    for (int i = 0; i < ${field.name}.length; i++) {
      buffer.setInt8(offset + i, ${field.name}[i]);
    }
    offset += ${field.name}.length;''',
        'int16_t' => '''
    for (int i = 0; i < ${field.name}.length; i++) {
      buffer.setInt16(offset, ${field.name}[i], Endian.big);
      offset += 2;
    }''',
        'int32_t' => '''
    for (int i = 0; i < ${field.name}.length; i++) {
      buffer.setInt32(offset, ${field.name}[i], Endian.big);
      offset += 4;
    }''',
        'float' => '''
    for (int i = 0; i < ${field.name}.length; i++) {
      buffer.setFloat32(offset, ${field.name}[i], Endian.big);
      offset += 4;
    }''',
        'uint8_t' => '''
    for (int i = 0; i < ${field.name}.length; i++) {
      buffer.setUint8(offset + i, ${field.name}[i]);
    }
    offset += ${field.name}.length;''',
        _ => '// TODO: Handle array type ${field.lcmType} for ${field.name}',
      };
    } else {
      return switch (field.lcmType) {
        'int8_t' => 'buffer.setInt8(offset, ${field.name}); offset += 1;',
        'int16_t' =>
          'buffer.setInt16(offset, ${field.name}, Endian.big); offset += 2;',
        'int32_t' =>
          'buffer.setInt32(offset, ${field.name}, Endian.big); offset += 4;',
        'int64_t' =>
          'buffer.setInt64(offset, ${field.name}, Endian.big); offset += 8;',
        'uint8_t' => 'buffer.setUint8(offset, ${field.name}); offset += 1;',
        'uint16_t' =>
          'buffer.setUint16(offset, ${field.name}, Endian.big); offset += 2;',
        'uint32_t' =>
          'buffer.setUint32(offset, ${field.name}, Endian.big); offset += 4;',
        'uint64_t' =>
          'buffer.setUint64(offset, ${field.name}, Endian.big); offset += 8;',
        'float' =>
          'buffer.setFloat32(offset, ${field.name}, Endian.big); offset += 4;',
        'double' =>
          'buffer.setFloat64(offset, ${field.name}, Endian.big); offset += 8;',
        'bool' =>
          'buffer.setUint8(offset, ${field.name} ? 1 : 0); offset += 1;',
        'string' => '''
    final ${field.name}Bytes = ${field.name}.codeUnits;
    buffer.setInt32(offset, ${field.name}Bytes.length + 1, Endian.big); offset += 4;
    for (int i = 0; i < ${field.name}Bytes.length; i++) {
      buffer.setUint8(offset + i, ${field.name}Bytes[i]);
    }
    buffer.setUint8(offset + ${field.name}Bytes.length, 0); // null terminator
    offset += ${field.name}Bytes.length + 1;''',
        _ => '// TODO: Handle type ${field.lcmType} for ${field.name}',
      };
    }
  }

  static String _generateDecodeField(LcmField field) {
    if (field.isArray) {
      return switch (field.lcmType) {
        'int8_t' => '''
    final ${field.name} = <int>[];
    for (int i = 0; i < ${field.arraySize}; i++) {
      ${field.name}.add(data.getInt8(offset + i));
    }
    offset += ${field.arraySize};''',
        'int16_t' => '''
    final ${field.name} = <int>[];
    for (int i = 0; i < ${field.arraySize}; i++) {
      ${field.name}.add(data.getInt16(offset, Endian.big));
      offset += 2;
    }''',
        'int32_t' => '''
    final ${field.name} = <int>[];
    for (int i = 0; i < ${field.arraySize}; i++) {
      ${field.name}.add(data.getInt32(offset, Endian.big));
      offset += 4;
    }''',
        'float' => '''
    final ${field.name} = <double>[];
    for (int i = 0; i < ${field.arraySize}; i++) {
      ${field.name}.add(data.getFloat32(offset, Endian.big));
      offset += 4;
    }''',
        'uint8_t' => '''
    final ${field.name} = <int>[];
    for (int i = 0; i < ${field.arraySize}; i++) {
      ${field.name}.add(data.getUint8(offset + i));
    }
    offset += ${field.arraySize};''',
        _ => '// TODO: Handle array type ${field.lcmType} for ${field.name}',
      };
    } else {
      return switch (field.lcmType) {
        'int8_t' => 'final ${field.name} = data.getInt8(offset); offset += 1;',
        'int16_t' =>
          'final ${field.name} = data.getInt16(offset, Endian.big); offset += 2;',
        'int32_t' =>
          'final ${field.name} = data.getInt32(offset, Endian.big); offset += 4;',
        'int64_t' =>
          'final ${field.name} = data.getInt64(offset, Endian.big); offset += 8;',
        'uint8_t' =>
          'final ${field.name} = data.getUint8(offset); offset += 1;',
        'uint16_t' =>
          'final ${field.name} = data.getUint16(offset, Endian.big); offset += 2;',
        'uint32_t' =>
          'final ${field.name} = data.getUint32(offset, Endian.big); offset += 4;',
        'uint64_t' =>
          'final ${field.name} = data.getUint64(offset, Endian.big); offset += 8;',
        'float' =>
          'final ${field.name} = data.getFloat32(offset, Endian.big); offset += 4;',
        'double' =>
          'final ${field.name} = data.getFloat64(offset, Endian.big); offset += 8;',
        'bool' =>
          'final ${field.name} = data.getUint8(offset) != 0; offset += 1;',
        'string' => '''
    final ${field.name}Length = data.getInt32(offset, Endian.big); offset += 4;
    final ${field.name}Bytes = bytes.sublist(offset, offset + ${field.name}Length - 1); // exclude null terminator
    final ${field.name} = String.fromCharCodes(${field.name}Bytes);
    offset += ${field.name}Length;''',
        _ => '// TODO: Handle type ${field.lcmType} for ${field.name}',
      };
    }
  }

  static String _generateSizeCalculation(LcmField field) {
    if (field.isArray) {
      return switch (field.lcmType) {
        'int8_t' || 'uint8_t' => 'size += ${field.arraySize};',
        'int16_t' || 'uint16_t' => 'size += ${field.arraySize} * 2;',
        'int32_t' || 'uint32_t' || 'float' => 'size += ${field.arraySize} * 4;',
        'int64_t' ||
        'uint64_t' ||
        'double' =>
          'size += ${field.arraySize} * 8;',
        _ =>
          'size += ${field.arraySize} * 4; // TODO: Verify size for ${field.lcmType}',
      };
    } else {
      return switch (field.lcmType) {
        'int8_t' || 'uint8_t' || 'bool' => 'size += 1;',
        'int16_t' || 'uint16_t' => 'size += 2;',
        'int32_t' || 'uint32_t' || 'float' => 'size += 4;',
        'int64_t' || 'uint64_t' || 'double' => 'size += 8;',
        'string' =>
          'size += 4 + ${field.name}.length + 1; // length + string + null terminator',
        _ => 'size += 4; // TODO: Verify size for ${field.lcmType}',
      };
    }
  }

  static int _calculateDataSize(List<LcmField> fields) {
    int size = 0;
    for (final field in fields) {
      if (field.isArray) {
        size += switch (field.lcmType) {
          'int8_t' || 'uint8_t' => field.arraySize,
          'int16_t' || 'uint16_t' => field.arraySize * 2,
          'int32_t' || 'uint32_t' || 'float' => field.arraySize * 4,
          'int64_t' || 'uint64_t' || 'double' => field.arraySize * 8,
          _ => field.arraySize * 4,
        };
      } else {
        size += switch (field.lcmType) {
          'int8_t' || 'uint8_t' || 'bool' => 1,
          'int16_t' || 'uint16_t' => 2,
          'int32_t' || 'uint32_t' || 'float' => 4,
          'int64_t' || 'uint64_t' || 'double' => 8,
          'string' => 4, // Just the length field for static calculation
          _ => 4,
        };
      }
    }
    return size;
  }

  static String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) =>
            word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join('');
  }
}

class LcmField {
  final String name;
  final String lcmType;
  final String dartType;
  final bool isArray;
  final int arraySize;

  LcmField(
      this.name, this.lcmType, this.dartType, this.isArray, this.arraySize);
}
