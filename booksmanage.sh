#! /bin/sh


rakuten_book_api=https://app.rakuten.co.jp/services/api/BooksBook/Search/20170404
app_id="アプリケーションID"
File_bookinfo=./mybook.txt

[ -f ./parsrj.sh ] || {
  curl -s https://raw.githubusercontent.com/ShellShoccar-jpn/Parsrs/master/parsrj.sh > parsrj.sh
}
[ -f ./parsrj.sh ] || { echo 'JSON parsr not available' 1>&2; exit 1; }


while :; do

  printf "ISBNコードを入力してください : "
  read isbn
  
  url="${rakuten_book_api}?applicationId=${app_id}&isbn=$isbn"

  res=$(curl -s "$url"                                   |
        sh ./parsrj.sh                                   |
        grep -E '^\$\.Items\[0\].Item.[A-Za-z]+ '        |
        awk '$1~/isbn/  {i=$0;sub(/^[^ ]* /,"",i);next;} #
             $1~/title/ {t=$0;sub(/^[^ ]* /,"",t);next;} #
             $1~/author/{a=$0;sub(/^[^ ]* /,"",a);next;} #
             END        {OFS="\t";print i,t,a;         }')

  case "${res#??}" in
    '') echo "${isbn}に該当する書籍がありません。";;
     *) echo "$res" >> $File_bookinfo             ;;
  esac
done
