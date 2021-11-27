## Instructions

Check the template [`.tex`](template/template.tex) and [`.pdf`](template/template.pdf) files to get understanding of what is about to happen: we're going to change the data values of the points.

1. Check out this repository:

  * [Codeberg](https://codeberg.org/paveloom-o/A-LaTeX-PGF-TikZ-Animation)
  * [GitHub](https://github.com/paveloom-o/A-LaTeX-PGF-TikZ-Animation)
  * [GitLab](https://gitlab.com/paveloom-g/other/a-latex-pgf-tikz-animation)
  * [SourceHut](https://sr.ht/~paveloom/A-LaTeX-PGF-TikZ-Animation)

2. Instantiate the Julia project:

    > **_NOTE:_**  You will need [Julia](https://julialang.org) installed.

    ```bash
    julia --project=. -e "using Pkg; Pkg.instantiate()"
    ```

3. Typeset the PDF frames:

    > **_NOTE:_**  You will need [`tectonic`](https://tectonic-typesetting.github.io) installed.

    ```bash
    julia --project=. frames.jl
    ```

    *or*

    ```bash
    ./julia.bash frames.jl
    ```

    The latter will start a Julia [daemon](https://github.com/dmolina/DaemonMode.jl) in the background. To kill it, run

    ```bash
    ./julia.bash kill
    ```

4. Convert the PDFs to PNGs:

    > **_NOTE:_**  You will need [`ImageMagick`](https://imagemagick.org) installed.

    ```bash
    ./frames.bash
    ```

4. Create a video and a GIF:

    > **_NOTE:_**  You will need [`FFmpeg`](https://ffmpeg.org) installed.

    ```bash
    ./video.bash
    ```

The results are [`example.mp4`](example.mp4) and [`example.gif`](example.gif):

![](example.gif)
