function data = read_breakout_board(filename)

fp = append("'", filename, "'");
pyrunfile(append("ONIX_Breakout_Board.py ", npyFilePath));

csvFilePath = append(filename(1:end-3), "csv");
T = readtable(csvFilePath, 'Decimal','.', 'Delimiter',',');
S = table2struct(T);
data = S;

delete(csvFilePath);