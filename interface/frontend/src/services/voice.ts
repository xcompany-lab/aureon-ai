export class VoiceService {
    private mediaRecorder: MediaRecorder | null = null;
    private audioChunks: Blob[] = [];
    private stream: MediaStream | null = null;
    private audioContext: AudioContext | null = null;
    private analyser: AnalyserNode | null = null;
    private dataArray: Uint8Array | null = null;
    private animationId: number | null = null;

    async startRecording(onLevelsUpdate?: (level: number) => void) {
        try {
            this.stream = await navigator.mediaDevices.getUserMedia({ audio: true });
            this.mediaRecorder = new MediaRecorder(this.stream);
            this.audioChunks = [];

            this.mediaRecorder.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    this.audioChunks.push(event.data);
                }
            };

            this.mediaRecorder.start();

            // Set up visualizer
            if (onLevelsUpdate) {
                this.audioContext = new AudioContext();
                const source = this.audioContext.createMediaStreamSource(this.stream);
                this.analyser = this.audioContext.createAnalyser();
                this.analyser.fftSize = 256;
                source.connect(this.analyser);

                const bufferLength = this.analyser.frequencyBinCount;
                this.dataArray = new Uint8Array(bufferLength);

                const updateLevels = () => {
                    if (this.analyser && this.dataArray) {
                        this.analyser.getByteFrequencyData(this.dataArray);
                        const average = this.dataArray.reduce((a, b) => a + b) / this.dataArray.length;
                        onLevelsUpdate(average);
                        this.animationId = requestAnimationFrame(updateLevels);
                    }
                };
                updateLevels();
            }

            return true;
        } catch (error) {
            console.error('Error starting recording:', error);
            return false;
        }
    }

    stopRecording(): Promise<Blob | null> {
        return new Promise((resolve) => {
            if (!this.mediaRecorder) {
                resolve(null);
                return;
            }

            this.mediaRecorder.onstop = () => {
                const audioBlob = new Blob(this.audioChunks, { type: 'audio/webm' });
                resolve(audioBlob);
                this.cleanup();
            };

            this.mediaRecorder.stop();
        });
    }

    private cleanup() {
        if (this.animationId) cancelAnimationFrame(this.animationId);
        if (this.stream) this.stream.getTracks().forEach(track => track.stop());
        if (this.audioContext && this.audioContext.state !== 'closed') this.audioContext.close();

        this.mediaRecorder = null;
        this.stream = null;
        this.audioContext = null;
        this.analyser = null;
        this.animationId = null;
    }
}

export const voiceService = new VoiceService();
