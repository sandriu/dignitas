alter table alias                        add modUserId int not null default 0;
alter table answer                       add modUserId int not null default 0;
alter table attachment                   add modUserId int not null default 0;
alter table attachment_reference         add modUserId int not null default 0;
alter table cookie                       add modUserId int not null default 0;
alter table entity                       add modUserId int not null default 0;
alter table entity_link                  add modUserId int not null default 0;
alter table flag                         add modUserId int not null default 0;
alter table object_tag                   add modUserId int not null default 0;
alter table password_token               add modUserId int not null default 0;
alter table relation                     add modUserId int not null default 0;
alter table relation_source              add modUserId int not null default 0;
alter table review                       add modUserId int not null default 0;
alter table review_log                   add modUserId int not null default 0;
alter table statement                    add modUserId int not null default 0;
alter table statement_source             add modUserId int not null default 0;
alter table tag                          add modUserId int not null default 0;
alter table user                         add modUserId int not null default 0;
alter table variable                     add modUserId int not null default 0;
alter table vote                         add modUserId int not null default 0;

alter table history_alias                        add modUserId int not null default 0;
alter table history_answer                       add modUserId int not null default 0;
alter table history_attachment                   add modUserId int not null default 0;
alter table history_attachment_reference         add modUserId int not null default 0;
alter table history_cookie                       add modUserId int not null default 0;
alter table history_entity                       add modUserId int not null default 0;
alter table history_entity_link                  add modUserId int not null default 0;
alter table history_flag                         add modUserId int not null default 0;
alter table history_object_tag                   add modUserId int not null default 0;
alter table history_password_token               add modUserId int not null default 0;
alter table history_relation                     add modUserId int not null default 0;
alter table history_relation_source              add modUserId int not null default 0;
alter table history_review                       add modUserId int not null default 0;
alter table history_review_log                   add modUserId int not null default 0;
alter table history_statement                    add modUserId int not null default 0;
alter table history_statement_source             add modUserId int not null default 0;
alter table history_tag                          add modUserId int not null default 0;
alter table history_user                         add modUserId int not null default 0;
alter table history_variable                     add modUserId int not null default 0;
alter table history_vote                         add modUserId int not null default 0;