" encoding: utf-8

" Load gems first time we execute the script
ruby << EOF
    require "rubygems"
    require "flay"

    VIM.command ":sign define piet text=>> texthl=Search"

    $signs = []
    $info  = {}
EOF

let s:processed_file=0

function! flay#execute()
    if match(expand("%:p"), '/.git/*') != -1
        return
    endif

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

    new_signs = []
    total_mass = 0

    flay.masses.each do |hash, mass|
        total_mass += mass
        hash = flay.hashes[hash]

        lines = hash.map(&:line)
        lines.each do |line|
            type = flay.identical[hash] ? "Identical" : "Similar"
            new_signs << line.to_i
            $info[line] = "#{type} code found, mass = #{mass}, lines = #{lines.join(",")}"
            VIM.command ":sign place #{line} name=piet line=#{line} file=#{VIM::Buffer.current.name}"
        end
    end

    ($signs - new_signs).each do |bad_sign|
        VIM.command ":sign unplace #{bad_sign}"
    end

    $signs = new_signs

    VIM.command ":echo 'Total Flay score (lower is better) = #{total_mass}'"
EOF
    let s:processed_file=1
endfunction

function! flay#clear_signs()
ruby << EOF
    $signs.each do |sign|
        VIM.command ":sign unplace #{sign}"
    end
    $signs = []
    $info  = {}
EOF

    let s:processed_file=0
endfunction

function! flay#draw_info()
ruby << EOF
    line = VIM.evaluate("line('.')").to_i
    if $signs.include?(line)
        VIM.command ":echo '#{$info[line]}'"
    else
        VIM.command ":echo ''"
    end
EOF
endfunction

function! flay#toggle()
    if s:processed_file
        call flay#clear_signs()
    else
        call flay#execute()
    endif
endfunction

function! flay#list()
ruby << EOF
    VIM.command ":echo 'Lines to flay = #{$signs.join(",")}'"
EOF
endfunction

" vim: ai tabstop=4 expandtab shiftwidth=4 softtabstop=4
