function out = serialRead(s)

while 1
    if s.BytesAvailable
        out = fscanf(s);
        break
    end
end
