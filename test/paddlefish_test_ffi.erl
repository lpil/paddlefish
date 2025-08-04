-module(paddlefish_test_ffi).
-export([main/0]).

main() ->
    PDF = eg_pdf:new(),
    % eg_pdf:set_pagesize(PDF, a4),
    % eg_pdf:set_page(PDF, 1),
    % eg_pdf:set_font(PDF, "Victorias-Secret", 40),
    % eg_pdf:begin_text(PDF),
    % eg_pdf:set_text_pos(PDF, 50, 700),
    % eg_pdf:text(PDF, "Hello Joe from Gutenberg"),
    % eg_pdf:end_text(PDF),
    {Serialised, PageCount} = eg_pdf:export(PDF),
    Serialised.
