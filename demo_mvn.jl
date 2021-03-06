# Demo of multivariate normal HMM using Viterbi algorithm and Baum-Welch.
include("models.jl")

module demo_mvn
using PyPlot
using Distributions
using MVNdiagHMM

# settings
m = 10
n = 1000
d = 5
tolerance = 1e-3

srand(1)

# parameters
p = round(rand(Dirichlet(ones(m))),2)
p[m] = 1-sum(p[1:m-1])
log_pi = log(p)
T = zeros(m,m)
alpha = 3.0
for r = 1:m
    T[r,:] = floor(rand(Dirichlet((alpha/m)*ones(m)))*100)/100
    T[r,m] = 1-sum(T[r,1:m-1])
end
log_T = log(T)
mu = round(4*randn(m,d),2)
sig = round(sqrt(rand(InverseGamma(1,2),(m,d))),2)
phi = [MvNormal(vec(mu[s,:]),vec(sig[s,:])) for s=1:m]

# simulate data
x,z0 = MVNdiagHMM.generate(n,log_pi,log_T,phi)

# compute optimal z
z = MVNdiagHMM.viterbi(x,log_pi,log_T,phi)

# compute naive z using each obs separately
z_naive = [indmax([MVNdiagHMM.log_q(x[i],phi[s]) for s=1:m]) for i=1:n]

# write to file
#writedlm("pi_T.txt",[p'; zeros(m)'; T])
#writedlm("mu_sig.txt",[mu; zeros(d)'; sig])
#writedlm("x.txt",[x[i][j] for i=1:n, j=1:d])
#writedlm("z_true.txt",z0)

# estimate parameters
log_pi_est,log_T_est,phi_est,log_m_est = MVNdiagHMM.estimate(x,m,tolerance)

# compute log marginal likelihood under the true parameters for comparison
G,log_m = MVNdiagHMM.forward(x,log_pi,log_T,phi)

# display results
println("\nViterbi percent correct:")
println(mean(z.==z0))
println("\nNaive percent correct:")
println(mean(z_naive.==z0))
println("\nLog marginal likelihood under true parameters:")
println(log_m)
println("\nLog marginal likelihood under estimated parameters:")
println(log_m_est)

# plots
x1 = Float64[xi[1] for xi in x]
m10 = Float64[mu[s,1] for s in z0]
m1p = Float64[mu[s,1] for s in z]
figure(1); clf(); hold(true)
plot(1:n,x1,"k.")
plot(1:n,m10,"b-")

figure(2); clf(); hold(true)
plot(1:n,z0,"b-",linewidth=2)
plot(1:n,z,"r--",linewidth=2)
plot(1:n,z_naive,"g:",linewidth=2)
xlim(0,100)


end # module



