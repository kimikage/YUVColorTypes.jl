
const Vec{T} = NTuple{3,T}
const Mat{T} = NTuple{3,Vec{T}} # three horizontal vectors

function mul(mat::Mat{T}, vec::Vec{T}) where {T}
    return Tuple(
        # reduce(+, mat[i] .* vec)
        muladd(mat[i][1], vec[1], muladd(mat[i][2], vec[2], mat[i][3] * vec[3]))
        for i in 1:3
    )
end

function mul(a::Mat{T}, b::Mat{T}) where {T}
    return Tuple(
        Tuple(
            # reduce(+, a[i] .* getindex.(b[:], j)
            muladd(a[i][1], b[1][j], muladd(a[i][2], b[2][j], a[i][3] * b[3][j]))
            for j in 1:3
        ) for i in 1:3
    )
end

function _inv(mat::Mat{T}) where {T}
    F = promote_type(T, Float64)
    imat = inv(F[mat[i][j] for i in 1:3, j in 1:3])
    return @inbounds Tuple(Tuple(imat[i, :]) for i in 1:3)
end

function _map(f, mat::Mat{T}) where T
    Tuple(map(f, v) for v in mat)
end
