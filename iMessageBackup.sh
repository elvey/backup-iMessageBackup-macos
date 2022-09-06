# This script takes in as input an iMessage account and backs its conversations up to a txt file.
# It also copies conversation pictures and other attachments that are cached locally to a directory.
#Parameter is an iMessage account (email or phone number i.e. +90212.... )
if [ $# -lt 1 ]; then
echo "Enter a iMessage account (email of phone number i.e +90212.....) "
fi
login=$1
DIR=~/Backups/Extracted_iMessage_Attachments${login}/
mkdir -p $DIR
#Retrieve the text messages
sqlite3 ~/Library/Messages/chat.db "
select is_from_me,text from message where handle_id=(
select handle_id from chat_handle_join where chat_id=(
select ROWID from chat where guid='iMessage;-;$login')
)" | sed 's/1\|/me: /g;s/0\|/bud: /g' > ~/Backups/MessageBackup${login}.txt
#Retrieve the attached stored in the local cache
sqlite3 ~/Library/Messages/chat.db "
select filename from attachment where rowid in (
select attachment_id from message_attachment_join where message_id in (
select rowid from message where cache_has_attachments=1 and handle_id=(
select handle_id from chat_handle_join where chat_id=(
select ROWID from chat where guid='iMessage;-;$login')
)))" | grep Messages | grep -v StickerCache | cut -c 2- | awk -v home=$HOME '{print home $0}' | tr '\n' '\0' | xargs -0 -t -I fname cp fname $DIR
open ~/Backups/MessageBackup${login}.txt
open $DIR
