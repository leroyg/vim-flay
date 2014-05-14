" encoding: utf-8

function! flay#execute()
    if filereadable( expand("%:p") )
        call flay#process_file()
    else
        echom "Failed to read file " . expand("%:p")
    endif
endfunction

function! flay#process_file()
ruby << EOF
    require "flay"

    VIM.command ":sign define piet text=>> texthl=Search"

    # Clear signs
    VIM.command ":silent sign unplace file=#{VIM::Buffer.current.name}"

    flay = Flay.new
    flay.process(VIM::Buffer.current.name)
    flay.analyze

    hash = {}
    flay.masses.map{|h, m| hash[m] = flay.hashes[h].map(&:line)}

    hash.each do |mass, lines|
        VIM.command ":echo '" + "Flay mass " + mass.to_s + ", lower is better'"
        lines.each do |line|
            VIM.command ":sign place #{line} name=piet line=#{line} file=#{VIM::Buffer.current.name}"
        end
    end
EOF
endfunction

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
