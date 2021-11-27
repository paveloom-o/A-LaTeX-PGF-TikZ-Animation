# This script substitutes the data points
# in the template and generates the PDF frames

println("> Loading the packages...")

using CSV

# Define the path to the data file
data_file = joinpath(@__DIR__, "template", "data.dat")

# Set the time difference between the points
Δt = 37

# Load the data
data = CSV.File(joinpath(@__DIR__, data_file); delim = " ", header = 0)
x = data[:Column1]
y = data[:Column2]

# Define the length of the data set
L = length(x)

# Prepare the temp directory
temp_dir = joinpath(@__DIR__, "temp")
mkpath(temp_dir)
cp(data_file, joinpath(temp_dir, basename(data_file)), force = true)

# Prepare the frames directory
frames_dir = joinpath(@__DIR__, "frames", "pdf")
mkpath(frames_dir)

# Define the paths to input/output files
temp_tex = joinpath(temp_dir, "temp.tex")
temp_pdf = joinpath(temp_dir, "temp.pdf")

"Print over the previous line"
function overprint(str)
    print("\u1b[1F")
    print(str)
    print("\u1b[0K")
    println()
end

println("> Typesetting... (1/$(L+1))")

for i = 0:L
    # Read the template
    t = open(joinpath(@__DIR__, "template", "template.tex"), "r") do io
        read(io, String)
    end

    if i == 0
        # Don't plot the points, plot everything else
        t = replace(t, "\\addplot[mark=*" => "% \\addplot[mark=*", count = 3)
    else
        # Reprint the status
        overprint("> Typesetting... ($(i+1)/$(L+1))")

        # Plot only points
        t = replace(t, "color=orange" => "color=orange, draw=none")
        t = replace(t, "\\node" => "% \\node")

        # Change the coordinates
        t = replace(t, "0.154, -0.0932" => "$(x[i]), $(y[i])")
        t = replace(t, "-0.1712, 0.2586" => "$(x[mod(i+Δt, 1:L)]), $(y[mod(i+Δt, 1:L)])")
        t = replace(t, "0.0467, 0.0096" => "$(x[mod(i+2Δt, 1:L)]), $(y[mod(i+2Δt, 1:L)])")
    end

    # Write the modified string to a file
    open(temp_tex, "w") do io
        write(io, t)
    end

    # Compile a PDF
    run(pipeline(`tectonic -X compile $temp_tex`, stdout = devnull))

    # Move the PDF to the frames directory
    mv(temp_pdf, joinpath(frames_dir, "$(i).pdf"); force = true)
end
