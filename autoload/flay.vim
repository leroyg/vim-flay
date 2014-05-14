" encoding: utf-8

" Load gems first time we execute the script
ruby << EOF
    require "rubygems"
    require "flay"

    VIM.command ":sign define piet text=>> texthl=Search"

    $signs = []
EOF

function! flay#execute()
    if filereadable( expand("%:p") )
        silent write
        call flay#process_file()
    else
        echoerr "Failed to read file " . expand("%:p")
    endif
endfunction

function! flay#process_file()
ruby << EOF
    flay = Flay.new
    flay.process(VIM::Buffer.current.name)
    flay.analyze

    hash = {}
    flay.masses.map{|h, m| hash[m] = flay.hashes[h].map(&:line)}

    new_signs = []
    total_mass = 0
    hash.each do |mass, lines|
        total_mass += mass
        lines.each do |line|
            new_signs << line
            VIM.command ":sign place #{line} name=piet line=#{line} file=#{VIM::Buffer.current.name}"
        end
    end

    ($signs - new_signs).each{|bad_sign| VIM.command ":sign unplace #{bad_sign}"}
    $signs = new_signs

    VIM.command ":echo 'Total Flay score (lower is better) = #{total_mass}'"
EOF
endfunction

function! flay#clear_signs()
ruby << EOF
    $signs.each do |sign|
        VIM.command ":sign unplace #{sign}"
    end
EOF
    redraw
endfunction

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
