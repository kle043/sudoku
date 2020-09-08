FROM julia:1.4

WORKDIR /app

COPY Project.toml .

COPY src src

RUN julia -e "using Pkg; pkg\"activate . \"; pkg\"instantiate\"; pkg\"precompile\"; using Sudoku"

ENTRYPOINT [ "julia", "--project=@.", "src/Main.jl" ]

CMD [ "--help" ]
