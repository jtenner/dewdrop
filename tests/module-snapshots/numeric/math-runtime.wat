(module
  (@custom "compiler.facts" (before first) "\01\00\01\07dewdrop\050.1.0\00\01\01\01\00\1f\00\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\00\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\01\01\00\00\00\00\00\00\00\00\00\01\00\02\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\7f\00\01\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\00\01\01\00\00\00\00\02\01\00\00\00\00\00\00\00\00\00\01\01\01\02\00\00\01\7f\00\01\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\00\01\01\00\00\00\00\03\01\00\00\00\00\00\00\00\00\00\01\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\04\01\00\00\00\00\00\00\00\00\00\01\01\03\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\05\01\81\80\10\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\06\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\04\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\07\01\00\00\00\00\00\00\00\00\00\01\01\02\02\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\7f\00\01\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\00\01\01\00\00\00\00\08\01\00\00\00\00\00\00\00\00\00\01\00\01\00\01\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\00\01\01\00\00\00\00\09\01\01\00\00\00\00\00\00\00\00\01\01\08\01\00\01\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\00\01\01\00\00\00\00\0a\01\01\00\00\00\00\00\00\00\00\01\00\03\00\00\01\7f\00\01\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\0b\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\0c\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\0d\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\0e\01\01\00\00\00\00\00\00\00\00\01\00\03\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\02\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\0f\01\81\81\80\02\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\10\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\11\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\12\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\13\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\10\11\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\14\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\10\11\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\15\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\16\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\17\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\00\01\00\00\01\7f\00\01\00\01\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\18\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\02\15\17\02\00\00\01\7f\00\01\00\01\7f\00\00\01\01\00\00\00\00\19\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\15\03\00\00\01\7f\00\01\00\01\7f\00\02\00\01\7f\00\00\01\01\00\00\00\00\1a\01\81\80\10\00\00\00\00\00\00\00\00\01\01\05\01\00\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\1b\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\01\06\02\00\00\01\7f\01\ff\01\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\01\01\00\00\00\00\1c\01\00\00\00\00\00\00\00\00\00\01\00\00\00\01\01\00\00\00\00\1d\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\04\00\1a\1b\1c\02\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\7f\00\01\00\01\7f\01\ff\01\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\01\00\00\00\00\1e\01\ff\ff\ff\03\00\00\00\00\00\00\00\00\01\10\07\09\0a\0b\0c\0d\0e\0f\10\12\13\14\16\18\19\1d\00\01\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\01\00\00\01\00\00\14\08\02\00\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\00\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\00\09\01\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\00\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\00\0a\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\0b\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\19\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\1a\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\00\1b\02\00\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\01\00\00\01\02\00\01\80\7f\ff\00\00\00\00\00\00\00\1c\01\00\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\01\00\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\00\1d\01\00\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\01\00\00\01\02\00\01\80\80~\ff\ff\01\00\00\00\00\00\00\22\03\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\02\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00$\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00%\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00)\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00*\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00+\00\01\00\00\01\02\01\00\01\00\01\fe\ff\ff\ff\0f\00\00\00\00\00\00.\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00/\01\01\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\01\00\01\80\fe\ff\ff\0f\00\00\00\00\00\000\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\002\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\003\00\01\00\00\01\02\01\00\ff\ff\ff\ff\0f\00\00\00\00\00\00\00\00\00\00\08\0b\02\0b\19\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b0\80\fc\ff\0f\01\a2\80\80\80\80\86\c0\ff\ff\01\01\a2\80\80\80\80\86\c0\ff\ff\01\00\01\8e(\00\0b%\00\00\00\00\00\01\01\01\01\00\00\13\00\01\01\b0\80\fc\ff\0f\01\a2\80\80\80\80\86\c0\ff\ff\01\01\a2\80\80\80\80\86\c0\ff\ff\01\00\01\8e(\00\00\00\00\00\02\0b\19\00\04\12\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\a2\80\80\80\80\86\c0\ff\ff\01\01\a2\80\80\80\80\86\c0\ff\ff\01\00\01\8e(\00\0b%\00\04\13\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\a2\80\80\80\80\86\c0\ff\ff\01\01\a2\80\80\80\80\86\c0\ff\ff\01\00\01\8e(\00\00\00\0c\04\0c\1a\00\00\00\00\00\01\01\01\01\00\00\16\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\0cZ\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\0cw\00\00\00\00\00\01\01\01\01\00\00\16\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\0c}\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\00\00\00\00\04\0c\1a\00\04\16\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\0cZ\00\04\12\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\0cw\00\04\16\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\0c}\00\04\12\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\b1\80\80\80\80\86\c0\ff\ff\01\01\b1\80\80\80\80\86\c0\ff\ff\01\00\01\d1;\00\00\00\0d\02\0d(\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b0\80\fc\ff\0f\01\b2\80\80\80\80\86\c0\ff\ff\01\01\b2\80\80\80\80\86\c0\ff\ff\01\00\01\eb>\00\0d7\00\00\00\00\00\01\01\01\01\00\00\16\00\01\01\b0\80\fc\ff\0f\01\b2\80\80\80\80\86\c0\ff\ff\01\01\b2\80\80\80\80\86\c0\ff\ff\01\00\01\eb>\00\00\00\00\00\02\0d(\00\04\12\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\b2\80\80\80\80\86\c0\ff\ff\01\01\b2\80\80\80\80\86\c0\ff\ff\01\00\01\eb>\00\0d7\00\04\16\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\b2\80\80\80\80\86\c0\ff\ff\01\01\b2\80\80\80\80\86\c0\ff\ff\01\00\01\eb>\00\00\00\0f\02\0f\17\00\00\00\00\00\01\01\01\01\00\00\12\00\01\01\b0\80\fc\ff\0f\01\dd\80\80\80\80\86\c0\ff\ff\01\01\dd\80\80\80\80\86\c0\ff\ff\01\00\01\fej\00\0f&\00\00\00\00\00\01\01\01\01\00\00\16\00\01\01\b0\80\fc\ff\0f\01\dd\80\80\80\80\86\c0\ff\ff\01\01\dd\80\80\80\80\86\c0\ff\ff\01\00\01\fej\00\00\00\00\00\02\0f\17\00\04\12\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\dd\80\80\80\80\86\c0\ff\ff\01\01\dd\80\80\80\80\86\c0\ff\ff\01\00\01\fej\00\0f&\00\04\16\00\00\00\00\00\01\01\b0\80\fc\ff\0f\01\dd\80\80\80\80\86\c0\ff\ff\01\01\dd\80\80\80\80\86\c0\ff\ff\01\00\01\fej\00\00\00\13\02\13(\00\01\01\01\00\00\01\00\01\00\00\01\01\b0\80\fc\ff\0f\01\ed\80\80\80\80\86\c0\ff\ff\01\01\e5\80\80\80\80\86\c0\ff\ff\01\00\01\cdv\00\132\00\01\01\01\00\00\01\00\01\00\00\01\01\b0\80\fc\ff\0f\01\ed\80\80\80\80\86\c0\ff\ff\01\01\e5\80\80\80\80\86\c0\ff\ff\01\00\01\cdv\00\00\00\00\00\00\00\00\14\02\14(\00\01\01\01\00\00\01\00\01\00\00\01\01\b0\80\fc\ff\0f\01\ee\80\80\80\80\86\c0\ff\ff\01\01\e6\80\80\80\80\86\c0\ff\ff\01\00\01\a9y\00\142\00\01\01\01\00\00\01\00\01\00\00\01\01\b0\80\fc\ff\0f\01\ee\80\80\80\80\86\c0\ff\ff\01\01\e6\80\80\80\80\86\c0\ff\ff\01\00\01\a9y\00\00\00\00\00\00\00\00\18\02\18(\00\01\01\02\00\00\01\01\01\00\00\01\01\b0\80\fc\ff\0f\01\fe\80\80\80\80\86\c0\ff\ff\01\01\ee\80\80\80\80\86\c0\ff\ff\01\00\01\a4\89\01\00\186\00\01\01\02\00\00\01\01\01\00\00\01\01\b0\80\fc\ff\0f\01\fe\80\80\80\80\86\c0\ff\ff\01\01\ee\80\80\80\80\86\c0\ff\ff\01\00\01\a4\89\01\00\00\00\00\00\00\00\00\1e\0e\1e\82\03\00\01\01\01\00\00\01\00\01\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\9b\03\00\01\01\01\00\00\01\00\01\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\ae\03\00\01\01\02\00\00\01\01\01\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\b7\03\00\01\01\02\80\80\80\80\80\80\80\f8?\00\01\01\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\d7\03\00\01\01\01\80\80\80\fc\03\00\01\00\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\ec\03\00\01\01\02\80\80\80\80\80\80\80\f8?\00\01\01\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\8c\04\00\01\01\01\80\80\80\fc\03\00\01\00\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\9b\04\00\01\01\02\80\80\80\80\80\80\80\f8?\00\01\01\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\a4\04\00\01\01\02\00\00\01\01\01\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\b6\04\00\01\01\01\80\80\80\83\04\00\01\00\04\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\e5\04\00\00\00\00\00\01\01\01\01\00\00C\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\ed\04\00\00\00\00\00\01\01\01\01\00\00E\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\87\05\00\00\00\00\00\01\01\01\01\00\00C\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\8f\05\00\00\00\00\00\01\01\01\01\00\00E\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\00\00\00\00\04\1e\e5\04\00\01C\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\ed\04\00\04E\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\87\05\00\01C\00\00\00\01\02\01\01\01\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\1e\8f\05\00\04E\00\00\00\00\00\01\01\b8\17\01\80\80\80\80\80\f7\02\01\80\80\80\80\80\f7\02\00\01%\00\00\00\00")
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 i32) (result i32)))
  (type (;9;) (func (param i32 i32) (result i32)))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i32) (result i32)))
  (type (;12;) (func (param i32) (result i32)))
  (type (;13;) (func (param i32) (result i32)))
  (type (;14;) (func (param i32) (result i32)))
  (type (;15;) (func (param i32) (result i32)))
  (type (;16;) (func (param i32) (result i32)))
  (type (;17;) (func (param v128) (result v128)))
  (type (;18;) (sub (struct (field i32))))
  (type (;19;) (sub final 18 (struct (field i32) (field i32))))
  (type (;20;) (sub final 18 (struct (field i32) (field eqref))))
  (type (;21;) (sub final 18 (struct (field i32) (field eqref))))
  (type (;22;) (sub final 18 (struct (field i32) (field i64))))
  (type (;23;) (sub final 18 (struct (field i32) (field eqref))))
  (type (;24;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;25;) (func (param eqref) (result i32)))
  (type (;26;) (func (param eqref i32) (result i32)))
  (type (;27;) (func (param i32 i32) (result i32)))
  (type (;28;) (func (param i32) (result i32)))
  (type (;29;) (func (param i32) (result i32)))
  (type (;30;) (func (param i32 i32 i32) (result i32)))
  (type (;31;) (func (param i32 i32) (result (ref 18))))
  (type (;32;) (func (param i64 i64) (result (ref 18))))
  (type (;33;) (func (param i64 i64) (result (ref 18))))
  (type (;34;) (func (param i32 i32 i32) (result i32)))
  (type (;35;) (func (param i64 i64) (result (ref 18))))
  (type (;36;) (func (param f32) (result i32)))
  (type (;37;) (func (param f32) (result i32)))
  (type (;38;) (func (param f32 f32) (result f32)))
  (type (;39;) (func (param f32 f32) (result f32)))
  (type (;40;) (func (param f32 f32) (result f32)))
  (type (;41;) (func (param f64) (result i32)))
  (type (;42;) (func (param f64) (result i32)))
  (type (;43;) (func (param f64) (result i32)))
  (type (;44;) (func (param f64 f64) (result f64)))
  (type (;45;) (func (param f64 f64 f64) (result f64)))
  (type (;46;) (func (param eqref) (result i32)))
  (type (;47;) (func (param eqref i32) (result i32)))
  (type (;48;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;49;) (func))
  (type (;50;) (func (param i32 eqref) (result i32)))
  (type (;51;) (func (result i32)))
  (type (;52;) (sub (struct (field funcref))))
  (type (;53;) (func (param eqref) (result eqref)))
  (type (;54;) (func (param eqref i32) (result eqref)))
  (type (;55;) (func (param eqref eqref) (result eqref)))
  (type (;56;) (func (param eqref)))
  (type (;57;) (func (param eqref i32)))
  (type (;58;) (func (param eqref) (result i32)))
  (type (;59;) (func (param eqref i32) (result i32)))
  (type (;60;) (func (param eqref eqref i32) (result eqref)))
  (type (;61;) (func (param eqref eqref eqref) (result eqref)))
  (type (;62;) (func (param eqref eqref)))
  (type (;63;) (func (param eqref eqref i32)))
  (type (;64;) (func (param eqref eqref) (result i32)))
  (type (;65;) (func (param eqref eqref i32) (result i32)))
  (type (;66;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;67;) (array (mut v128)))
  (type (;68;) (struct (field (ref 67)) (field i32) (field i32)))
  (type (;69;) (struct (field (ref 67)) (field i32) (field i32)))
  (type (;70;) (struct (field (ref 67)) (field i32) (field i32)))
  (type (;71;) (struct (field (mut (ref 67))) (field (mut i32)) (field (mut i32))))
  (type (;72;) (struct (field (mut (ref 67))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 48)))
  (memory (;0;) 1)
  (export "main" (func 30))
  (export "memory" (memory 0))
  (func (;1;) (type 8) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.add
    i32.extend8_s
  )
  (func (;2;) (type 9) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;3;) (type 10) (param i32) (result i32)
    local.get 0
    i32.const 255
    i32.and
  )
  (func (;4;) (type 11) (param i32) (result i32)
    local.get 0
    call 3
  )
  (func (;5;) (type 25) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 69)
    struct.get 69 2
  )
  (func (;6;) (type 26) (param eqref i32) (result i32)
    (local (ref 24) i32 v128 v128 v128)
    local.get 0
    ref.cast (ref 24)
    ref.cast (ref 24)
    local.set 2
    local.get 1
    local.get 2
    ref.cast (ref 24)
    struct.get 24 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const -1
      local.get 2
      ref.cast (ref 24)
      struct.get 24 1
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
    local.get 2
    ref.cast (ref 24)
    struct.get 24 1
    local.get 1
    i32.add
    local.set 3
    local.get 2
    ref.cast (ref 24)
    struct.get 24 0
    ref.cast (ref 4)
    local.get 3
    i32.const 4
    i32.shr_u
    array.get 4
    local.set 4
    local.get 3
    i32.const 15
    i32.and
    call 4
    i8x16.splat
    local.set 5
    local.get 4
    local.set 6
    local.get 6
    local.get 5
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;7;) (type 27) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    call 2
  )
  (func (;8;) (type 28) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      i32.const 0
      local.get 0
      i32.sub
      i32.extend16_s
    else
      local.get 0
    end
  )
  (func (;9;) (type 29) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    i32.eq
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      call 8
    end
  )
  (func (;10;) (type 30) (param i32 i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_s
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      local.get 1
      i32.lt_s
      if (result i32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 2
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 2
        else
          local.get 0
        end
      end
    end
  )
  (func (;11;) (type 31) (param i32 i32) (result (ref 18))
    (local i32 i32)
    local.get 0
    local.get 1
    i32.add
    local.set 2
    local.get 0
    local.get 2
    i32.xor
    local.get 1
    local.get 2
    i32.xor
    i32.and
    i32.const 0
    i32.lt_s
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 18
    else
      local.get 2
      local.set 3
      i32.const 1
      local.get 3
      struct.new 19
    end
    ref.cast (ref 18)
  )
  (func (;12;) (type 32) (param i64 i64) (result (ref 18))
    (local i64 i64 i64)
    local.get 0
    i64.const 0
    i64.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i64.const 0
      i64.eq
    end
    if (result eqref) ;; label = @1
      i64.const 0
      local.set 3
      i32.const 1
      local.get 3
      struct.new 22
    else
      local.get 0
      i64.const -9223372036854775808
      i64.eq
      if (result i32) ;; label = @2
        local.get 1
        i64.const -1
        i64.eq
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 1
        i64.const -9223372036854775808
        i64.eq
        if (result i32) ;; label = @3
          local.get 0
          i64.const -1
          i64.eq
        else
          i32.const 0
        end
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 18
      else
        local.get 0
        local.get 1
        i64.mul
        local.set 2
        local.get 2
        local.get 1
        i64.div_s
        local.get 0
        i64.eq
        if (result eqref) ;; label = @3
          local.get 2
          local.set 4
          i32.const 1
          local.get 4
          struct.new 22
        else
          i32.const 0
          struct.new 18
        end
      end
    end
    ref.cast (ref 18)
  )
  (func (;13;) (type 33) (param i64 i64) (result (ref 18))
    (local i64)
    local.get 1
    i64.const 0
    i64.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i64.const -9223372036854775808
      i64.eq
      if (result i32) ;; label = @2
        local.get 1
        i64.const -1
        i64.eq
      else
        i32.const 0
      end
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 18
    else
      local.get 0
      local.get 1
      i64.div_s
      local.set 2
      i32.const 1
      local.get 2
      struct.new 22
    end
    ref.cast (ref 18)
  )
  (func (;14;) (type 34) (param i32 i32 i32) (result i32)
    local.get 1
    local.get 2
    i32.gt_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
      local.get 1
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 2
        i32.gt_u
        if (result i32) ;; label = @3
          local.get 2
        else
          local.get 0
        end
      end
    end
  )
  (func (;15;) (type 35) (param i64 i64) (result (ref 18))
    (local i64)
    local.get 1
    i64.const 0
    i64.ne
    if (result i32) ;; label = @1
      local.get 0
      i64.const -1
      local.get 1
      i64.div_u
      i64.gt_u
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 18
    else
      local.get 0
      local.get 1
      i64.mul
      local.set 2
      i32.const 1
      local.get 2
      struct.new 22
    end
    ref.cast (ref 18)
  )
  (func (;16;) (type 36) (param f32) (result i32)
    local.get 0
    local.get 0
    f32.ne
  )
  (func (;17;) (type 37) (param f32) (result i32)
    local.get 0
    i32.reinterpret_f32
    i32.const -2147483648
    i32.and
    i32.const 0
    i32.ne
  )
  (func (;18;) (type 38) (param f32 f32) (result f32)
    local.get 0
    i32.reinterpret_f32
    i32.const 2147483647
    i32.and
    local.get 1
    i32.reinterpret_f32
    i32.const -2147483648
    i32.and
    i32.or
    f32.reinterpret_i32
  )
  (func (;19;) (type 39) (param f32 f32) (result f32)
    local.get 0
    call 16
    if (result f32) ;; label = @1
      local.get 0
    else
      local.get 1
      call 16
      if (result f32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 1
        f32.lt
        if (result f32) ;; label = @3
          local.get 0
        else
          local.get 1
          local.get 0
          f32.lt
          if (result f32) ;; label = @4
            local.get 1
          else
            local.get 0
            f32.const 0x0p+0 (;=0;)
            f32.eq
            if (result i32) ;; label = @5
              local.get 1
              f32.const 0x0p+0 (;=0;)
              f32.eq
            else
              i32.const 0
            end
            if (result f32) ;; label = @5
              local.get 0
              call 17
              if (result f32) ;; label = @6
                local.get 0
              else
                local.get 1
              end
            else
              local.get 0
            end
          end
        end
      end
    end
  )
  (func (;20;) (type 40) (param f32 f32) (result f32)
    local.get 0
    call 16
    if (result f32) ;; label = @1
      local.get 0
    else
      local.get 1
      call 16
      if (result f32) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 1
        f32.gt
        if (result f32) ;; label = @3
          local.get 0
        else
          local.get 1
          local.get 0
          f32.gt
          if (result f32) ;; label = @4
            local.get 1
          else
            local.get 0
            f32.const 0x0p+0 (;=0;)
            f32.eq
            if (result i32) ;; label = @5
              local.get 1
              f32.const 0x0p+0 (;=0;)
              f32.eq
            else
              i32.const 0
            end
            if (result f32) ;; label = @5
              local.get 0
              call 17
              if (result f32) ;; label = @6
                local.get 1
              else
                local.get 0
              end
            else
              local.get 0
            end
          end
        end
      end
    end
  )
  (func (;21;) (type 41) (param f64) (result i32)
    local.get 0
    local.get 0
    f64.ne
  )
  (func (;22;) (type 42) (param f64) (result i32)
    local.get 0
    i64.reinterpret_f64
    i64.const 9223372036854775807
    i64.and
    i64.const 9218868437227405312
    i64.eq
  )
  (func (;23;) (type 43) (param f64) (result i32)
    local.get 0
    i64.reinterpret_f64
    i64.const -9223372036854775808
    i64.and
    i64.const 0
    i64.ne
  )
  (func (;24;) (type 44) (param f64 f64) (result f64)
    local.get 0
    call 21
    if (result f64) ;; label = @1
      local.get 0
    else
      local.get 1
      call 21
      if (result f64) ;; label = @2
        local.get 1
      else
        local.get 0
        local.get 1
        f64.gt
        if (result f64) ;; label = @3
          local.get 0
        else
          local.get 1
          local.get 0
          f64.gt
          if (result f64) ;; label = @4
            local.get 1
          else
            local.get 0
            f64.const 0x0p+0 (;=0;)
            f64.eq
            if (result i32) ;; label = @5
              local.get 1
              f64.const 0x0p+0 (;=0;)
              f64.eq
            else
              i32.const 0
            end
            if (result f64) ;; label = @5
              local.get 0
              call 23
              if (result f64) ;; label = @6
                local.get 1
              else
                local.get 0
              end
            else
              local.get 0
            end
          end
        end
      end
    end
  )
  (func (;25;) (type 45) (param f64 f64 f64) (result f64)
    local.get 1
    call 21
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      call 21
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      local.get 2
      f64.gt
    end
    if (result f64) ;; label = @1
      unreachable
    else
      local.get 0
      call 21
      if (result f64) ;; label = @2
        local.get 0
      else
        local.get 0
        local.get 1
        f64.lt
        if (result f64) ;; label = @3
          local.get 1
        else
          local.get 0
          local.get 2
          f64.gt
          if (result f64) ;; label = @4
            local.get 2
          else
            local.get 0
          end
        end
      end
    end
  )
  (func (;26;) (type 46) (param eqref) (result i32)
    local.get 0
    call 5
  )
  (func (;27;) (type 47) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 6
  )
  (func (;28;) (type 49))
  (func (;29;) (type 50) (param i32 eqref) (result i32)
    (local i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 1
    call 26
    local.set 2
    i32.const 0
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 12
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 2
              local.get 3
              i32.sub
              local.set 4
              local.get 4
              i32.const 65520
              i32.gt_u
              if (result i32) ;; label = @6
                i32.const 65520
              else
                local.get 4
              end
              local.set 5
              i32.const 0
              local.set 10
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 10
                      local.set 6
                      local.get 6
                      local.get 5
                      i32.lt_u
                      if ;; label = @10
                        i32.const 16
                        local.get 6
                        i32.add
                        local.get 1
                        local.get 3
                        local.get 6
                        i32.add
                        call 27
                        i32.store8
                        local.get 6
                        i32.const 1
                        i32.add
                        local.set 10
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 28
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              i32.const 0
              local.set 11
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 11
                      local.set 7
                      local.get 7
                      local.get 5
                      i32.lt_u
                      if ;; label = @10
                        local.get 5
                        local.get 7
                        i32.sub
                        local.set 8
                        i32.const 0
                        i32.const 16
                        local.get 7
                        i32.add
                        i32.store
                        i32.const 4
                        local.get 8
                        i32.store
                        i32.const 8
                        i32.const 0
                        i32.store
                        local.get 0
                        i32.const 0
                        i32.const 1
                        i32.const 8
                        call 0
                        i32.const 0
                        i32.ne
                        if ;; label = @11
                          unreachable
                        else
                          i32.const 8
                          i32.load
                          local.set 9
                          local.get 9
                          i32.const 0
                          i32.eq
                          if (result i32) ;; label = @12
                            i32.const 1
                          else
                            local.get 9
                            local.get 8
                            i32.gt_u
                          end
                          if ;; label = @12
                            unreachable
                          else
                            local.get 7
                            local.get 9
                            i32.add
                            local.set 11
                            br 5 (;@7;)
                          end
                          unreachable
                        end
                        unreachable
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 28
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 3
              local.get 5
              i32.add
              local.set 12
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
            local.set 13
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 13
  )
  (func (;30;) (type 51) (result i32)
    (local f32 f64 f32 f64 eqref eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref i32)
    i32.const 2143294004
    f32.reinterpret_i32
    local.set 0
    i64.const 9221120237041095220
    f64.reinterpret_i64
    local.set 1
    i32.const -2147483648
    f32.reinterpret_i32
    local.set 2
    i64.const -9223372036854775808
    f64.reinterpret_i64
    local.set 3
    i32.const 2147483647
    i32.const 1
    call 11
    local.set 4
    i64.const -1
    i64.const 2
    call 15
    local.set 5
    i64.const 3037000499
    i64.const 3037000499
    call 12
    local.set 6
    i32.const 127
    i32.const 1
    call 7
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    i32.eq
    if (result i32) ;; label = @1
      i32.const 0
      i32.const 32767
      i32.sub
      i32.extend16_s
      call 9
      i32.const 32767
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 11
      i32.const 0
      i32.const 10
      call 10
      i32.const 10
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 3
      i32.const 4
      i32.const 9
      call 14
      i32.const 4
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 4
      local.set 8
      block ;; label = @2
        local.get 8
        ref.cast (ref 18)
        struct.get 18 0
        i32.const 0
        i32.eq
        if ;; label = @3
          i32.const 1
          local.set 9
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 9
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 9
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 5
      local.set 10
      block ;; label = @2
        local.get 10
        ref.cast (ref 18)
        struct.get 18 0
        i32.const 0
        i32.eq
        if ;; label = @3
          i32.const 1
          local.set 11
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 11
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 11
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 6
      local.set 12
      block ;; label = @2
        local.get 12
        ref.cast (ref 18)
        struct.get 18 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 12
          ref.cast (ref 22)
          struct.get 22 1
          i64.const 9223372030926249001
          i64.eq
        else
          i32.const 0
        end
        if ;; label = @3
          i32.const 1
          local.set 13
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 13
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 13
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i64.const -9223372036854775808
      i64.const -1
      call 13
      local.set 14
      block ;; label = @2
        local.get 14
        ref.cast (ref 18)
        struct.get 18 0
        i32.const 0
        i32.eq
        if ;; label = @3
          i32.const 1
          local.set 15
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 15
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 15
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x0p+0 (;=0;)
      local.get 2
      call 19
      i32.reinterpret_f32
      i32.const -2147483648
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 2
      f32.const 0x0p+0 (;=0;)
      call 20
      i32.reinterpret_f32
      i32.const 0
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 3
      f64.const 0x0p+0 (;=0;)
      f64.const 0x1p+0 (;=1;)
      call 25
      i64.reinterpret_f64
      i64.const -9223372036854775808
      i64.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      f32.const 0x1p+0 (;=1;)
      call 19
      i32.reinterpret_f32
      i32.const 2143294004
      i32.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f64.const 0x1p+0 (;=1;)
      local.get 1
      call 24
      i64.reinterpret_f64
      i64.const 9221120237041095220
      i64.eq
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x1p+0 (;=1;)
      f32.neg
      f32.sqrt
      call 16
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f64.const 0x1p+0 (;=1;)
      f64.const 0x0p+0 (;=0;)
      f64.div
      call 22
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      f32.const 0x1.cp+1 (;=3.5;)
      local.get 2
      call 18
      i32.reinterpret_f32
      i32.const -1067450368
      i32.eq
    else
      i32.const 0
    end
    local.set 7
    local.get 7
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x656d756e 0x3a636972 0x6874616d 0x00000000
      array.new_fixed 67 1
      i32.const 0
      i32.const 12
      struct.new 69
      call 29
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 67 1
      i32.const 0
      i32.const 4
      struct.new 69
      call 29
    end
  )
)
