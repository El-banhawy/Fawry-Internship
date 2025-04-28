#!/bin/bash

# تهيئة متغيرات الخيارات
show_line_number=false
invert_match=false

# دالة لعرض معلومات الاستخدام
usage() {
  echo "Usage: $0 [-n] [-v] <pattern> <filename>"
  exit 1
}

# التحقق من علامة --help أولاً
if [ "$1" = "--help" ]; then
  usage
fi

# تحليل الخيارات
while getopts "nv" opt; do
  case "$opt" in
    n)
      show_line_number=true
      ;;
    v)
      invert_match=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done
shift $((OPTIND - 1))

# التحقق من عدد الوسائط
if [ "$#" -ne 2 ]; then
  echo "Error: Missing pattern and/or filename." >&2
  usage
fi

pattern="$1"
filename="$2"

# التحقق من وجود الملف
if [ ! -f "$filename" ]; then
  echo "Error: File '$filename' not found." >&2
  exit 1
fi

line_number=1

# قراءة الملف سطرًا بسطر والبحث عن النمط
while IFS= read -r line; do
  # تحويل السطر والنمط إلى أحرف صغيرة للمقارنة غير الحساسة لحالة الأحرف
  lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
  lower_pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')

  # تنفيذ grep والحصول على حالة الخروج
  grep -q "$lower_pattern" <<< "$lower_line"
  grep_result=$?

  if [ "$invert_match" = true ]; then
    if [ "$grep_result" -ne 0 ]; then
      if [ "$show_line_number" = true ]; then
        echo "$line_number:$line"
      else
        echo "$line"
      fi
    fi
  else
    if [ "$grep_result" -eq 0 ]; then
      if [ "$show_line_number" = true ]; then
        echo "$line_number:$line"
      else
        echo "$line"
      fi
    fi
  fi
  ((line_number++))
done < "$filename"